+++
title = "Async Getting Started"
draft = false
date = "2016-10-28T09:00:00Z"
type = "post"
Tags = ["CSharp","Async"]

+++

During initial days of my career, I was working on a project which required regular cleanup of invalid users based on a log and validation with LDAP. As with many of us, software engineers, a repetitive task gives us the urge to automate it. With that feeling I started working on a tool, based on win forms, to be able to cleanup the users. This cleanup process took about 2-4 minutes based on the size of the log file. My initial version of the application had a button, which upon clicking would make the window unresponsive for the aforementioned duration and then come back with list of invalid users. However, as we know that is not a great experience even for an internal tool to be used by a team. Read on, to find out how we can solve the above problem with the latest available C# features

Improving the over all responsiveness of the application while avoiding performance bottlenecks is always desirable and one of the possibilities to achieve that is using asynchronous programming. The usual options to be able to achieve the same are Threading, Thread pools, BackgroundWorker component, Task Parallel Library etc. The latest addition to this list is Task-based Asynchronous Pattern(TAP, referred the same way hereafter). 

Introduced in .Net framework 4.5 (C# 5) the TAP is based on two classes [Task](https://msdn.microsoft.com/en-us/library/system.threading.tasks.task(v=vs.110).aspx) & [Task< TResult >](https://msdn.microsoft.com/en-us/library/dd321424(v=vs.110).aspx) in System.Threading.Tasks namespace. Unlike the previous asynchronous pattern which was based on IAsyncResult which contained Begin & End methods, the TAP is only based on a single method. As a standard practice, these methods are suffixed with the word Async (an example, [ExecuteReaderAsync](https://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlcommand.executereaderasync(v=vs.110).aspx)).

The method signatures of TAP methods would be exactly same as the ones that we would have for synchronous methods. Again, this is different from the previous ways of doing asynchronous programming where we were required to pass standard parameters and wrap our data inside them.

> Note: We cannot have async methods with ref or out parameters because of limitations of the CLR and also because of the implementation of the async pattern. More on this can be read at [http://stackoverflow.com/questions/18716928/how-to-write-a-async-method-with-out-parameter](http://stackoverflow.com/questions/18716928/how-to-write-a-async-method-with-out-parameter)

TAP methods are usually implemented to do a small amount of synchronous work before returning a Task. To be able to implement TAP, the long running method would be marked with async keyword and will be returning a Task (or Task<TResult>) which gives us the ability to look at the status of the task later. The TAP method is responsible for choosing where asynchronous execution occurs and the potential context couldbe a ThreadPool, asynchronous I/O, specific thread like UI thread etc. 

Caller of the async method can either making a blocking wait on the asynchronous method or utilize a "continuation". A continuation can simply be considered as a bookmark from which the execution of the method must continue once the asynchronous method execution completes. An await keyword is used for marking the "continuation" and the method will effectively return from the method.

As the saying goes "A picture is worth a thousand words" and in our context "A code snippet is worth a thousand words" :-)

```csharp
void Main()
{
	Console.WriteLine("Main method begins execution");
	Console.WriteLine(Thread.CurrentThread.ManagedThreadId);
	WriteLineAsync("The usual Hello, World!!");
	Console.WriteLine(Thread.CurrentThread.ManagedThreadId);
	Console.WriteLine("Main method is done executing");
}

static Task WriteLineAsync(string text)
{
	return Task.Run(() => WriteLine(text));
}

static void WriteLine(string text)
{
	//Something here takes 2 seconds. duh!!
	Thread.Sleep(2000);
	Console.WriteLine(text);
	Console.WriteLine($"My thread id is {Thread.CurrentThread.ManagedThreadId}");
}
```

The output would give more clarity on what is happening

```csharp
Main method begins execution
12
12
Main method is done executing
The usual Hello, World!!
My thread id is 21
```

Long after the Main method execution completes (2 seconds in our case) the execution of the asynchronous method was complete which proves to us that our application would be responsive while the asynchronous operation is going on. Observe that the ManagedThreadId is 12 during the course of Main method execution while the Task was scheduled on a different ManagedThreadId

> Note: Please note that the ManagedThreadId could differ when you execute the code on your machine. Also, do not forget to add the namespace System.Threading.Tasks

Now, let us look at the scenario where we need the result of the asynchronous method before continuing but somehow don't want to block the current thread. Let's look at the code

```csharp
// This the first modification that we need to make
// However, async void is bad and we would discuss that in the next blog post
async void Main()
{
	Console.WriteLine("Main method begins execution");
	Console.WriteLine(Thread.CurrentThread.ManagedThreadId);
	// Scheduling a continuation using await keyword
	await WriteLineAsync("The usual Hello, World!!");
	Console.WriteLine(Thread.CurrentThread.ManagedThreadId);
	Console.WriteLine("Main method is done executing");
}

static Task WriteLineAsync(string text)
{
	return Task.Run(() => WriteLine(text));
}

static void WriteLine(string text)
{
	//Something here takes 2 seconds. duh!!
	Thread.Sleep(2000);
	Console.WriteLine(text);
	Console.WriteLine($"My thread id is {Thread.CurrentThread.ManagedThreadId}");
}
```

The output

```csharp
Main method begins execution
12
The usual Hello, World!!
My thread id is 19
19
Main method is done executing
```

This output is slightly different from the one that we saw in the previous example. This is because once the await keyword was encountered a "continuation" was scheduled and the current thread for freed. That is the reason after the Task was executed when the "continuation" on Main method started executing we see that the ManagedThreadId is different(12 vs 19).

This is fundamental way the TAP along with language features of async & await transform the way we deal with asynchronous programming. No more crazy juggling of context between threads and suffering to pass data the "right" way between them.

Stay tuned for the next blog post in this series where we would go beyond the basics and also look at some best practices. Till then, Happy coding or as [Carl](https://www.dotnetrocks.com/#section_5) puts it "Go write some code"