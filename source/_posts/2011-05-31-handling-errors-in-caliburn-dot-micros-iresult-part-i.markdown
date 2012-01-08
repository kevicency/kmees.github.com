---
layout: post
title: "Handling Errors in Caliburn.Micro's IResult - Part I"
date: 2011-05-31 22:01
comments: true
categories:
- MVVM
- C#
- Caliburn.Micro
---
## The Problem

One of Caliburn.Micro's nicest feature is, hands down, the concept of Actions. In that concept the `IResult` plays an important role, especially when using *Coroutines*. If you don't know about them, you should definately [read up on them here first](http://devlicio.us/blogs/rob_eisenberg/archive/2010/08/21/caliburn-micro-soup-to-nuts-part-5-iresult-and-coroutines.aspx).

So, let's assume we are executing a Coroutine which does the following: 

  * show a loading screen to the user,
  * start processing a lot of data
  * hide the loading screen once the processing is finished.

Since the processing is also likely to fail for whatever reason we want to handle the error by executing a *Rescue Coroutine*.

``` csharp Pseudo Coroutine
public IEnumerable ProcessData()
{
    yield return new BusyResult("Processing...");

    yield return new ProcessDataResult();

    yield return new NotBusyResult();
}
```
The implementation of those results is irrelevant since we want to have a look at how we can handle the error during the processing in a nice (reusable) way.

<!--more-->

## The First Attempt

Well, let's see how we can handle it at all. The first approach is to ignore the built-in mechanism and expose an error property on the result which will then be checked during the execution of the Coroutine.

``` csharp
public IEnumerable ProcessData()
{
    yield return new BusyResult("Processing...");

    var processDataResult = new ProcessDataResult();
    yield return processDataResult;

    if (processDataResult.Error != null)
    {
        // We could use Coroutine.BeginExecute(Rescue().GetEnumerator()); but than the context would be null
        foreach (var rescueResult in Rescue())
        {
            yield return rescueResult;
        }
        yield break;
    }
    else
    {
        yield return new NotBusyResult();
    }
}

public IEnumerable<IResult> Rescue()
{
    yield return new NotBusyResult();

    // more rescue stuff
}

public class ProcessDataResult : IResult
{
    public Exception Error { get; private set; }

    public void Execute(ActionExecutionContext context)
    {
        try
        {
            //process the data
        }
        catch (Exception e)
        {
            Error = e;
        }

        Completed(this, new ResultCompletionEventArgs());
    }

    public event EventHandler<ResultCompletionEventArgs> Completed;
}
```
Although this works, there are some *problems* with this approach.

  * We need to add an error property to each result where an error is likely (which may not be always possible)
  * The syntax for executing the Rescue Coroutine is quite ugly and not easy to comprehend
  * The method itself gets exponentially more complex for every result which can fail
  * Calling different rescues for different error is tideous

## The Better Attempt

The second approach uses the built-in mechanism by raising the Completed Event with the Error roperty of the ResultCompletitionEventArgs set to the actual error.

``` csharp
public IEnumerable<IResult> ProcessData()
{
    yield return new BusyResult("Processing...");

    var processDataResult = new ProcessDataResult();
    processDataResult.Completed += (sender, args) =>
                                       {
                                           if (args.Error != null)
                                               Coroutine.BeginExecute(Rescue().GetEnumerator());
                                       };

    yield return processDataResult;

    yield return new NotBusyResult();
}

public IEnumerable<IResult> Rescue()
{
    yield return new NotBusyResult();

    // more rescue stuff
}

public class ProcessDataResult : IResult
{
    public void Execute(ActionExecutionContext context)
    {
        try
        {
            //process the data
        }
        catch (Exception e)
        {
            Completed(this, new ResultCompletionEventArgs { Error = e });
        }

        Completed(this, new ResultCompletionEventArgs());
    }

    public event EventHandler<ResultCompletionEventArgs> Completed;
}
```

With this approach we don't need to add an extra property to our Result which is a huge gain but there are still some *disadvantages*.

  * We 'lose' the context in the Rescue Coroutine
  * Syntax still not optimal
  * Calling different rescues is still tedious

## The Final Solution

So, what we want is basically

  * a nice syntax,
  * something that works for every implementation of IResult,
  * execute the Rescue Coroutine with the same context as the failing Coroutine,
  * and a way to handle different types of errors

Whew, that's quite a bit to ask for. Let's have a look at the first two points. Since we want it to work on *every* implementation of IResult, we cannot use inheritance but how about an Extension Method for IResults together with some *fluent syntax*?

``` csharp
public IEnumerable<IResult> ProcessData()
{
    yield return new BusyResult("Processing...");

    yield return new ProcessDataResult()
        .Rescue<IOException>().With(coroutine: IORescue)
        .Rescue().With(coroutine: GeneralRescue);

    yield return new NotBusyResult();
}

public IEnumerable<IResult> IORescue(IOException exception)
{
    yield return new NotBusyResult();

    // more rescue stuff
}

public IEnumerable<IResult> GeneralRescue(Exception exception)
{
    yield return new NotBusyResult();

    // more rescue stuff
}
```

That doesn't look too bad, does it?

But since this post got really long, I will show the implementation of the solution in the next part. So you either wait for the next post.
