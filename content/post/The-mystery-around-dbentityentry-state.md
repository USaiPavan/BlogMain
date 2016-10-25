+++
title = "The mystery around DbEntityEntry.State"
draft = false
date = "2016-07-06T09:00:00-05:00"
author = "Sai Pavan"

+++

While playing around with EF DbContext ChangeTracker API I happened to observe an interesting behavior of DbContext.Entry().State. I will be using AdventureWorks database with Code First from database for this blog post. Initially I have obtained a row using the Find method on the Addresses entity. Now I have called the Entry method on the DbContext to obtain the DbEntityEntry< Address > and accessed the State property on the same. As expected, the State was "Unchanged". Now I have modified the AddressLine1 to add some dummy information and tried to get obtain the State again. Here is the code snippet

~~~ csharp

		var localContext = new AdventureWorksModel();
        var firstResult = localContext.Addresses.Find(10);

        var entryDetails = localContext.Entry(firstResult);
        Console.WriteLine(entryDetails.State);

        firstResult.AddressLine1 += "test";

        Console.WriteLine(entryDetails.State);

~~~ 

What do you think the result would have been?

~~~ csharp

	Unchanged
	Unchanged

~~~

My initial thoughts were since the call to Entry method was creating a new object there is no way this object would have any idea and all was good. However, I happened to call localContext.Entry(firstResult) and then tried to access entryDetails.State. Before I reveal the result. Here is the code. Give it a guess


~~~ csharp

		var localContext = new AdventureWorksModel();
        var firstResult = localContext.Addresses.Find(10);

        var entryDetails = localContext.Entry(firstResult);
        Console.WriteLine(entryDetails.State);

        firstResult.AddressLine1 += "test";
        

        Console.WriteLine(entryDetails.State);
        Console.WriteLine(localContext.Entry(firstResult).State);
        Console.WriteLine(entryDetails.State);

~~~ 

Here is the result

~~~ csharp
		
	Unchanged
	Unchanged
	Modified
	Modified
~~~ 

Now this was a surprise for me, if both the instances were different then how come one affected the other. Were they the same? I confirmed that they weren't

~~~ csharp

		Console.WriteLine(localContext.Entry(firstResult) == entryDetails);
~~~ 

Result:

~~~ csharp
		
	False
~~~ 


It triggered my curiosity and I decided to dig into EntityFramework.dll to get my answers. I used dotPeek to be able to decompile the same

Looks like the Entry method on the DbContext internally calls DetectChanges() with force option true which will cause the ObjectStateManager to refresh and detect that the changes have been made. However, by just calling State property again on the existing DbEntityEntry won't help because though it uses ObjectStateManager behind the scenes the DetectChanges hasn't been called and hence the details won't be updated. Below are the screenshots of the code and the debugging state. 


![Entry](/20160706-DetectChangesOnCallingEntryMethod.JPG)

![Context](/20160706-StatePropertyAccessingInternalContext.png)

Also, by calling DetectChanges on the DbContext.ChangeTracker, we can ensure that the existing DbEntityEntry is updated

~~~ csharp
 		var localContext = new AdventureWorksModel();
	    var firstResult = localContext.Addresses.Find(10);
	
	    var entryDetails = localContext.Entry(firstResult);
	    Console.WriteLine(entryDetails.State);
	
	    firstResult.AddressLine1 += "test";
	
	    localContext.ChangeTracker.DetectChanges();
	    
	
	    Console.WriteLine(entryDetails.State);
	    Console.WriteLine(localContext.Entry(firstResult).State);
	    Console.WriteLine(entryDetails.State);
	
	    Console.WriteLine(localContext.Entry(firstResult) == entryDetails);
~~~