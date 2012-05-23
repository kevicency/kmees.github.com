---
layout: page
title: "CMContrib"
sharing: true
comments: true
footer: true
---

<a href="http://github.com/kmees/cmcontrib"><img style="position: absolute; top: 0; right: 0; border: 0; box-shadow: 0pt 0pt 0pt transparent;" src="https://a248.e.akamai.net/assets.github.com/img/7afbc8b248c68eb468279e8c17986ad46549fb71/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67" alt="Fork me on GitHub"></a>

Extensions for the [Caliburn.Micro](http://caliburnmicro.codeplex.com/) MVVM Framework.

## Nuget Package
The CMContrib NuGet package is available at the NuGet gallery under the name [Caliburn.Micro-Contrib](http://nuget.org/packages/Caliburn.Micro-Contrib)

## Demo

<div id="silverlightControlHost">
  <object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="100%" height="600">
    <param name="source" value="../sl/Caliburn.Micro.Contrib.SL.Demo.xap"/>
    <param name="background" value="white" />
    <param name="minRuntimeVersion" value="4.0.60310.0" />
    <param name="autoUpgrade" value="true" />
    <a href="http://go.microsoft.com/fwlink/?LinkID=149156&v=4.0.60310.0" style="text-decoration:none">
      <img src="http://go.microsoft.com/fwlink/?LinkId=161376" alt="Get Microsoft Silverlight" style="border-style:none"/>
    </a>
  </object>
</div>

## Features

### MVVM Dialogs
Easy way to show dialogs to the user. There are four predefined Dialogs

- Information
- Warning
- Question
- Error
 
For more Information see [Blog post](http://kmees.github.com/blog/2011/06/16/mvvm-dialogs-with-caliburn-dot-micro/).

### IResult Implementation

####SL & WPF:

- *BusyResult* - Locates an implementation of IBusyIndicator by searching the Visual Tree or by injecting it and activates/deactivates it.
- *DialogResult* - Creates a modal DialogWindow for a Dialog, shows it to the user and stroes the response in a Property. Also enables you to automatically cancel the result for a specific answer.
- *OpenChildResult* - Activate a ViewModel in a specific Conductor
- *DelegateResult* - Wraps an arnitrary Action in a Result.

####WPF only:

- *SaveFileResult* - Result wrapper for a SaveFileDialog with fluent configuration
- *OpenFileResult* - Result wrapper for an OpenFileDialog with fluent configuration
- *BrowseFolderResult* - Result wrapper for a BroseFolderDialog with fluent configuration

### IResult Extensions
CMContrib provides several chainable Extension Methods for IResult

- *Rescue&lt;TException&gt;()* - Decorates the result with an error handler which is executed when an error occurs.
- *WhenChancelled()* - Decorates the result with an handler which is executed when the result was cancelled.
- *AsCoroutine()* - Returns an IEnumerable&lt;IResult&gt; which yields the IResult.
- *OnWorkerThread()* - Executes the Result on a dedicated worker thread and activates the given IBusyIndactor if a message is given.

### Filter
Filters are part of the full Caliburn framework. They are quite useful because they enable AOP for coroutine. Some of them are re-implemented here as Attributes

- *Rescue* - Decorates the coroutine with an error handler which es executed when an error occurs during execution
- *OnWorkerThread* - Delegates the execution of the coroutine to a background thread and activates the IBusyIndicator if a message is given

### Syntax Extensions

- *XamlBinding* - Parses Xaml Bindings ({Binding ...}) in ActionMessages, i.e Message.Attach="DoSomething({Binding Text, ElementName=UserInput})"
- *SpecialValueProperty* - Parses Properties of Special Values in ActionMessages, i.e. Message.Attach="DoSomething($eventargs.Foo)"

### Design Time Support
CMContrib allows you to enable Caliburn's auto binding feature during design time with an Attached Property
