+++
title = "Simpler way to convert Nullable type to Value type"
draft = false
date = "2016-03-18T09:00:00-05:00"
author = "Sai Pavan"
Tags = ["C#"]

+++

The more we work with databases, more is the need for [nullable types](https://msdn.microsoft.com/en-us/library/1t3y8s4s.aspx). This is because of the inherent difference between the way value types are treated in object oriented world and the relational world. In the object oriented world the value types always have a value either the one that we assign or the one that is the default value. However, in the database world they are treated differently. They are assigned as a data type for a column and it is possible that the column has a value of the column could have NULL (obviously, not in case of NOT NULL columns). Now when this is to be translated back into object oriented languages like C# resort to something like nullable types. ORMs like Entity Framework also use a similar approach.

Now when these values have to be converted from Nullable value types to normal C# value types we have to be careful in not running into InvalidOperationException

```csharp
// Following line of code throws a InvalidOperationException
// with message as
// Nullable object must have a value.
DateTime? sourceValue = null;
DateTime destinationValue = sourceValue.Value;
```

In order to be able to avoid such an issue we must then resort to a HasValue check and when the value exists it will have to be assigned by calling the Value property of the nullable type otherwise we will assign the default value of that particular type

```csharp	
DateTime? sourceValue = null;
DateTime destinationValue;
if (sourceValue.HasValue)
{
	destinationValue = sourceValue.Value;	
}
else
{
	destinationValue = default(DateTime);
}
```

The above code is very verbose and if we have to resort to writing this kind of code for every nullable type to value type conversion in our code it quickly starts to become cumbersome. [Extension methods](https://msdn.microsoft.com/en-us/library/bb383977.aspx) have come to my rescue to be able to solve this issue in a more cleaner way. I have written an [generic extension](http://stackoverflow.com/questions/4928810/how-do-i-write-an-extension-method-for-a-generic-type-with-constraints-on-type-p) method on Nullable<T> such that it will take the nullable value type and checks for HasValue. In case it has a value then the Value property will be returned. Otherwise, default value of that particular value type will be returned


```csharp
public static class MyExtensions
{
	// Generic extension method which checks for HasValue and based on that
	// will return a value
	public static T ToValueType<T>(this Nullable<T> inputValue) where T : struct
	{
		if (inputValue.HasValue)
		{
			return inputValue.Value;
		}
		return default(T);
	}
}

void Main()
{
	//Extension method usage
	DateTime? sourceValue = null;
	DateTime destinationValue;
	destinationValue = sourceValue.ToValueType();

	Console.WriteLine($"Destination value for datetime is : {destinationValue} ");
	
	int? sourceIntValue = 1;
	int destinationIntValue;
	destinationIntValue = sourceIntValue.ToValueType();
	
	Console.WriteLine($"Destination value for datetime is : {destinationIntValue} ");
}

// Result is as follows
// Destination value for datetime is : 1/1/0001 12:00:00 AM 
// Destination value for datetime is : 1 

```