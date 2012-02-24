---
layout: post
title: "Context-Based Views for Dialogs"
date: 2012-02-24 11:32
comments: true
categories: 
- CMContrib
- MVVM
- WPF
- SL
---
## Retrospect
In my [CMContrib Project](/projects/cmcontrib.html) I use a MVVM approach for
showing dialogs to the user. The model for the dialog has a _dialog type_
(Question, Error,...), a _subject_ (or title), a _message_ and a list of
possible _responses_ the user can choose from. The default response in CMContrib
is an Answer enum with values for _Ok, Cancel, Yes_ and all the other standard
answers but you can also use a complex type as a response.

Here's an example of how to ask the user a question and cancel the coroutine
when the user responses with _No_.
``` csharp
public override IEnumerable<IResult> AskAQuestion()
{
    var question = new Question("The Subject",
        "The Message",
        Answer.Yes,
        Answer.No);

    yield return question.AsResult()
        .CancelOnResponse(Answer.No);

    // ...
}
```

## One View to show them all (again)
The call `.AsResult()` on a dialog wraps it in a `DialogViewModel` which is then
passed to Caliburn.Micro's `IWindowManager` and shown as a modular dialog. The problem
with that approach is, that the same default view, which is `Caliburn.Micro.Contrib.Dialogs.DialogView` unless you added a namespace alias, is resolved for all types of dialogs. Now, if you need a special view for, let's say errors only, you are in trouble.

But fear not, because Caliburn already has a solution to that problem, namely _view contexts_, which are explained [here](http://devlicio.us/blogs/rob_eisenberg/archive/2010/11/18/caliburn-micro-soup-to-nuts-part-6d-a-billy-hollis-hybrid-shell.aspx). Since each dialog already has a _dialog type_ we can use that as our view context. The change to show the context based view instead of the default view couldn't be easier, it's just one line in the `DialogResult`
``` csharp
public IEnumerable<IResult> Execute()
{
    IDialogViewModel<TResponse> vm = _locateVM();
    vm.Dialog = Dialog;

    // ommitted unrelevant parts

    // show without context
    // Micro.Execute.OnUIThread(() => IoC.Get<IWindowManager>().ShowDialog(vm));
    Micro.Execute.OnUIThread(() => IoC.Get<IWindowManager>().ShowDialog(vm, Dialog.DialogType));
}
```
Now the default view for an _Error_ is `Caliburn.Micro.Contrib.Dialogs.Error`.
Okay cool, but what happens if we want to show a _Question_? Well, we get an
error because there is looks for the view
`Caliburn.Micro.Contrib.Dialogs.Question` which doesn't exist and which we don't
want to create. Instead, we want to use the default `DialogView` as a fallback view.

## Changing the ViewLocator
Since we want to change the way how views are located, the `ViewLocator` might
be a good class to look at. The function responsible for locating the view type for
a view model type is called `LocateTypeForModelType`. In a nutshell, this function takes the
type of the view model and the view context, transforms those into a list of
possible view type names and searches for a type in the assemblies that matches
one of the names. If none is found, `null` will be returned and Caliburn.Micro
shows the "Could not locate view for ..." error view that you might have seen
before.
``` csharp
public static Func<Type, DependencyObject, object, Type> LocateTypeForModelType = (modelType, displayLocation, context) => {
    var viewTypeName = modelType.FullName;

    if (Execute.InDesignMode) {
        viewTypeName = ModifyModelTypeAtDesignTime(viewTypeName);
    }

    viewTypeName = viewTypeName.Substring(
        0,
        viewTypeName.IndexOf("`") < 0
            ? viewTypeName.Length
            : viewTypeName.IndexOf("`")
        );

    var viewTypeList = TransformName(viewTypeName, context);
    var viewType = viewTypeList.Join(AssemblySource.Instance.SelectMany(a => a.GetExportedTypes()), n => n, t => t.FullName, (n, t) => t).FirstOrDefault();

    if(viewType == null) {
        Log.Warn("View not found. Searched: {0}.", string.Join(", ", viewTypeList.ToArray()));
    }

    return viewType;
};
```
Now, we basically have two options. Either we replace the function with one that
tries to locate the view without a context when the default function returns
null or we replace the `TransformName` function to also return the type names
without a view context.
I opted for the second options because it is easier to implement and other
function that use `TransformName` benefit from that change, too.
``` csharp
static readonly Func<string,object, IEnumerable<string>> _baseTransformName = Micro.ViewLocator.TransformName;

static IEnumerable<string> FallbackNameTransform(string typeName, object context)
{
    var names = _baseTransformName(typeName, context);
    if (context != null)
    {
        names = names.Union(_baseTransformName(typeName, null));
    }

    return names;
}
```
The implementation is pretty straight-forward. Since the `ViewLocator` returns the first view type found, we simply append the name(s) of the fallback view(s) to the list of names given by: the default `TransformName`.

## Even more customization !
If you need a different view for _Errors_ and _Questions_, you might also need
different views for different _Questions_! Let's say we have views named
`My.Namespace.FooQuestion` and `My.Namespace.BarQuestion` which we want to use for different
kinds of Questions. We add a `ContextPrefix` to the `DialogResult` and create
the view context by concatenating the `ContextPrefix` and `DialogType`. Adding a
fluent configuration for the prefix to the `DialogResult` gives us this nice
syntax to for showing the `FooQuestion` view.
``` csharp
public override IEnumerable<IResult> Execute()
{
    var question = new Dialog<SpecialAnswer>(DialogType.Question,
        "Why am I so uncreative",
        new SpecialAnswer("Because!"),
        new SpecialAnswer("Dunno."));

    yield return question.AsResult()
        .PrefixViewContextWith("Foo");
}
```

## Appendix
### I: Note on Namespace aliases
In case you don't want to put your custom dialog views in the `Caliburn.Micro.Contrib.Dialogs` namespace, just add a namespace alias the `ViewLocator`
```
ViewLocator.AddSubNamespaceMapping("Caliburn.Micro.Contrib.Dialogs", "My.Namespace.Views");
```

### II: Online Silverlight Demo
Although I added an example for this feature to the Silverlight demo, it
currently crashes each browser when embedded in a page. Out-of-browser works
though. If you know why, tell me ! Will update the demo once it works.
