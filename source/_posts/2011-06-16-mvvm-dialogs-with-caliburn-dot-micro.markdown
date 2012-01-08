---
layout: post
title: "MVVM Dialogs with Caliburn.Micro"
date: 2011-06-16 21:10
comments: true
categories:
- MVVM
- C#
- Caliburn.Micro
- WPF
- SL
---
## Background

In every applications life there comes a time when you need to show some kind of message to the user. Be it a question whether he really wants to delete something or a simple message that says that some operation was successful. The most simple way to do that is the good ol' `MessageBox.Show()` with its zillion overloads.

``` csharp
MessageBox.Show("Foo", "Bar", MessageBoxButton.OKCancel);
```

But in the shiny MVVM World , polluting your ViewModels with MessageBoxes is usually frowned upon since it breaks a lot of stuff, especially automated unit testing and theming.

You can find quite a lot solutions about how the MVVM*ize* MesasgeBoxes and dialog screens in general. Most of them involve wrapping the `MessageBox.Show()` in some kind of IService, setting up some kind of event infrastructure and other funky stuff. Surprisingly, all of those solutions completely ignore the first M in **M**VVM, namely the Model, and none really tackles the problem at its heart.

<!--more-->

## Implementation

### One Model to rule them all

Well, let's forget about all the View and ViewModel stuff for now. We will start by specifying what we actually want to achieve with a dialog.

We want to display some message concerning some topic and a list of possible Responses from which the user can choose one.

So, let's create a model with conforms to those specifications

``` csharp Dialog&lt;TResponse&gt;
public class Dialog<TResponse>
{
    public DialogType DialogType { get; set; }
    public string Subject { get; set; }
    public string Message { get; set; }

    public IEnumerable<TResponse> PossibleResponses { get; protected set; }
    public TResponse GivenResponse {get; set; }
    public bool IsResponseGiven { get; private set; }
}
```

``` csharp DialogType
public enum DialogType
{
    None,
    Question,
    Warning,
    Information,
    Error
}
```

The DialogType in conjunction with the subject defines the topic and the rest is pretty much straightforward. We also need a IsResponseGiven Property so that we can distinguish between default and unset values because TResponse may or may not be a value type (and hence not nullable).

### One ViewModel to bind them

The ViewModel is responsible for bringing the Responses in a bindable format and setting the response on the dialog when the user selects one. The ViewModel also handles the case where the user closes the window without giving any response at all.

For supporting default (the user presses `Enter`) and cancel (the user presses `Escape`) responses,  I will use a convention based approach, namely defining the first response in the list as the default response and the last response as the cancel response.

``` csharp BindableResponse&lt;TResponse&gt;
public class BindableResponse<TResponse>
{
    public TResponse Response { get; set; }
    public bool IsDefault { get; set; }
    public bool IsCancel { get; set; }
}
```

``` csharp IDialogViewModel&lt;TResponse&gt;
public interface IDialogViewModel<TResponse>
{
    bool IsClosed { get; set; }
    Dialog<TResponse> Dialog { get; set; }
    IObservableCollection<BindableResponse<TResponse>> Responses { get; }
    void Respond(BindableResponse<TResponse> bindableResponse);
}
```

The implementation is pretty straightforward and omitted for brevity but can be found here.

### One View to show them all

I will present the WPF version of the view here because the SL version requires a workaround for the non existing `IsDefault`/`IsCancel` Properties of the Button. For those interested in the SL version, the source is here. I will also omit all irrelevant (styling) properties.

``` xml DialogView
<Window x:Class="Caliburn.Micro.Contrib.Interaction.DialogView"       
        Title="{Binding Dialog.Subject}"
        Contrib:DialogCloser.DialogResult="{Binding CanClose}">
    <Window.Icon>
        <Binding Path="Dialog.DialogType">
            <Binding.Converter>
                <Converter:DialogTypeToSystemIconConverter />
            </Binding.Converter>
        </Binding>
    </Window.Icon>
    <DockPanel Focusable="False" LastChildFill="True">
        <ItemsControl x:Name="Responses">
            <ItemsControl.ItemTemplate>
                <DataTemplate>
                    <Button Content="{Binding Response}"
                            IsCancel="{Binding IsCancel}"
                            IsDefault="{Binding IsDefault}"
                            Micro:Message.Attach="Respond($dataContext)" />
                </DataTemplate>
            </ItemsControl.ItemTemplate>
        </ItemsControl>
        <TextBlock Text="{Binding Dialog.Message}" />
    </DockPanel>
</Window>
```

The most important part is where we bind the Responses to an ItemsControl (by using Caliburn.Micros Convention Binding Feature) and create a Button for each Response which will call the Respond() Method on the ViewModel with the bound Response as a parameter. The Subject of the Dialog is bound to the Title of the Window and the DialogType is converted to an Icon.

### And with the IResult show them

No Caliburn.Micro Extension with the corresponding IResult to use them !

To actually show the dialog to the user, we would have to

  * Create the dialog
  * Import the IWindowManager in the ViewModel
  * Create the ViewModel and pass it the dialog
  * Invoke ShowDialog() on the IWindowManager with the ViewModel as a parameter

Well, the first step cannot be encapsulated in an IResult, but 2-4 rest can easily be encapsulated.

``` csharp DialogResult&lt;TResponse&gt;
public class DialogResult<TResponse> : IResult
{
    private Func<IDialogViewModel<TResponse>> _locateVM =
        () => new DialogViewModel<TResponse>();

    public DialogResult(Dialog<TResponse> dialog)
    {
        Dialog = dialog;
    }

    public Dialog<TResponse> Dialog { get; private set; }

    public void Execute(ActionExecutionContext context)
    {
        IDialogViewModel<TResponse> vm = _locateVM();
        vm.Dialog = Dialog;
        Micro.Execute.OnUIThread(() => IoC.Get<IWindowManager>().ShowDialog(vm));
    }

    public DialogResult<TResponse> In(IDialogViewModel<TResponse> dialogViewModel)
    {
        _locateVM = () => dialogViewModel;
        return this;
    }

    public DialogResult<TResponse> In<TDialogViewModel>()
        where TDialogViewModel : IDialogViewModel<TResponse>
    {
        _locateVM = () => IoC.Get<TDialogViewModel>();
        return this;
    }
}
```

We do not only get reusable code, but also a nice way to change the implementation of IDialogViewModel<> for specific dialogs if we want to.

Last but not least we can write a small Extension Method to get even more readable code !

``` csharp
public static DialogResult<TResponse> AsResult<TResponse>(this Dialog<TResponse> dialog)
        {
            return new DialogResult<TResponse>(dialog);
        }
```

And use it in the coroutine

``` csharp Demo
public IEnumerable<IResult> Foo()
{
    var question = new Dialog<Answer>(DialogType.Question,
                                      "Isn't this a nice way to create a Dialog Window?",
                                      Answer.Yes,
                                      Answer.No);

    yield return question.AsResult();

    if (question.GivenResponse == Answer.Yes)
        Console.WriteLine(" ^_^ ");
    else
        Console.WriteLine(" :*( ");
}
```
