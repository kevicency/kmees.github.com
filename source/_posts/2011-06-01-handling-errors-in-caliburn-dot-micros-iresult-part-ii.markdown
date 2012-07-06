---
layout: post
title: "Handling Errors in Caliburn.Micro's IResult - Part II"
date: 2011-06-01 23:01
comments: true
categories:
- MVVM
- C#
- Caliburn.Micro
---
## Preface

In my last post I gave two possible approaches and a preview of my final solution for handling errors in IResults. The syntax for my final solution was

``` csharp
yield return new ProcessDataResult()
        .Rescue().With(coroutine: IORescue)
        .Rescue().With(coroutine: GeneralRescue);
```

This means that

  * whenever the result completes with an error of type IOException, the IORescue coroutine is executed
  * whenever the result completes with any other error, the GeneralRescue coroutine is executed

So the behaviour of the Rescue is similar to a try/catch block

``` csharp
try {}
catch (IOException e) { //IORescue }
catch (Exception e) { //GeneralRescue }
```

<!--more-->

## Decorators to the Rescue !

Now, before we have a look at the implementation, you should make yourself familiar with the [Decorator Pattern](http://en.wikipedia.org/wiki/Decorator_pattern) since we will use a Decorator to 'extend' the behaviour of the Execute-Method of our Inner Result.

Well, let's start with a base class for our decorators.

``` csharp
internal class ResultDecoratorBase : IResult
{
    private readonly IResult _inner;

    protected ResultDecoratorBase(IResult inner)
    {
        if (inner == null) throw new ArgumentNullException("inner");

        _inner = inner;
    }

    public IResult Inner
    {
        get { return _inner; }
    }

    #region IResult Members

    public virtual void Execute(ActionExecutionContext context)
    {
        var wrapper = new SequentialResult(new SingleResultEnumerator(_inner));
        wrapper.Completed += InnerCompleted;

        wrapper.Execute(context);
    }

    public virtual event EventHandler Completed;

    #endregion

    protected virtual void OnCompleted(ResultCompletionEventArgs args)
    {
        if (Completed != null)
            Completed(this, args);
    }

    protected virtual void InnerCompleted(object sender, ResultCompletionEventArgs args)
    {
        (sender as IResult).Completed -= InnerCompleted;
    }
}
```

The base Decorator takes an arbitrary IResult and, when executed, wraps it in a SequentialResult (to get some benefits like build up by the IoC) and executes it. The InnerCompleted()-Method is the hook for the inheriting Decorators to perform their logic.

## The Rescue Decorator

The Rescue Decorator will be generic (for the type that we want to catch) and takes a Function in its constructor which taked an exception as an argument and returns the Rescue Coroutine. We can also specify if we always want to cancel the Result after the rescue was executed.

``` csharp
/// <summary>
///   A result decorator which executes a coroutine when the inner result completes with an error
/// </summary>
/// <typeparam name = "TException">The type of the exception we want to perform the rescue on</typeparam>
internal class RescueCoroutineDecorator<TException> : ResultDecoratorBase
    where TException : Exception
{
    private readonly bool _cancelResult;
    private readonly Func<TException, IEnumerable<IResult>> _rescue;

    public RescueCoroutineDecorator(IResult inner, Func<TException, IEnumerable<IResult>> rescue, bool cancelResult)
        : base(inner)
    {
        if (rescue == null) throw new ArgumentNullException("rescue");

        _rescue = rescue;
        _cancelResult = cancelResult;
    }
}
```

In the InnerCompleted()-Method we check if the Inner Result completed with an error of type TException and if so, execute the Rescue Coroutine. If not, we ignore the error and raise the Completed-Event with the same args.


``` csharp
protected override void InnerCompleted(object sender, ResultCompletionEventArgs args)
{
    base.InnerCompleted(sender, args);

    if (args.Error is TException)
    {
        var error = (TException)args.Error;

        LogRescuedError(error);

        try
        {
            Rescue(error);
        }
        catch (Exception e)
        {
            Log.Error(e);
            OnCompleted(new ResultCompletionEventArgs { Error = e });
        }
    }
    else
    {
        OnCompleted(args);
    }
}

private void Rescue(TException exception)
{
    var rescueResult = new SequentialResult(_rescue(exception).GetEnumerator());
    rescueResult.Completed += RescueCompleted;

    rescueResult.Execute(_context);
}
```

Then, when the Rescue Coroutine completed, the Decorator will also complete. Since we execute the Rescue inside the execution of the Decorator we can also check if the Rescue completes successfully and react accordingly (like setting the error on the EventArgs or cancel it)

``` csharp
private void RescueCompleted(object sender, ResultCompletionEventArgs args)
{
    (sender as IResult).Completed -= RescueCompleted;

    OnCompleted(new ResultCompletionEventArgs { Error = args.Error, WasCancelled = args.WasCancelled || CancelResult });
}
```

The full code for the Rescue Decorator can be found here.

## Recap

Well, with the Decorator Pattern it was possible to implement all the desired features in a nice and testable way. Furthermore, we can use same principle for executing a coroutine when the result is cancelled or when an exception is thrown inside the result.
