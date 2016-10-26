+++
title = "Trim extra spaces in strings on objects recursively"
draft = false
date = "2016-02-27T09:00:00-05:00"
author = "Sai Pavan"
Tags = ["C#"]

+++

Many of us might have had requirement to be able to trim extra spaces in strings on custom classes that we have created, at some point in our career.These extra spaces in strings might have come from a database or maybe from an external system. These not only cause waste of bandwidth but also causes the problem in terms of  comparison. Especially when working on APIs that will be used by mobile applications every byte that is being sent across the wire matters. 

I was in a similar scenario where we were sending JSON data to client application and we had to ensure that data being sent to application has as much low memory footprint as possible.When trying to trim spaces in the strings it was easy for custom classes which only had primitive types in them. However, it gets complicated as the custom classes start having complex objects. It gets more tricky when there are list of objects inside these custom classes. The solution that I could come up with was using reflection and recursion to achieve the final result. After a few iterations and clarifications on [StackOverflow](http://stackoverflow.com/questions/35234810/trim-spaces-in-a-object-recursively-using-reflection) here is the final solution.

I have created an extension method on object which handles a generic parameter. As a first step I have first trimmed all the strings at the object level. I have done this using reflection and link where we will identify all the strings and just trim the spaces on them which is symbol. 

```csharp
//Iterates all properties and trims the values if they are strings
var properties = obj.GetType().GetProperties(BindingFlags.Instance | 	BindingFlags.Public)
    .Where(prop => prop.PropertyType == typeof(string))
    .Where(prop => prop.CanWrite && prop.CanRead);

foreach (var property in properties)
{
    var value = (string) property.GetValue(obj, null);
    if (value.HasValue())
    {
    var newValue = (object) value.Trim();
    property.SetValue(obj, newValue, null);
    }
}
```

As a next step I tried to take care of all the list of objects so that they can each be operated individually and spaces can be trimmed on them. To be able to achieve this I have relied on recursion.

```csharp
// This is to take care of Lists. This iterates through each value
// in the list.
// For example, Countries which is a List<Country>
var baseTypeInfo = obj.GetType().BaseType;
if (baseTypeInfo != null && baseTypeInfo.FullName.Contains("List"))
{
    var listCount = (int) obj.GetType().GetProperty("Count").GetValue(obj, null);
    for (var innerIndex = 0; innerIndex < listCount; innerIndex++)
    {
	    var item = obj.GetType().GetMethod("get_Item", new[] {typeof(int)}).Invoke(obj, new object[] {innerIndex});
	    item.TrimSpaces(); // Recursive call
    }
}
```
Now as the last step I have taken care of other custom objects inside the object so that  also be taken care of item in the spaces.

```csharp
    // Now once we are in a complex type (for example Country) it then needs to
    // be trimmed recursively using the initial peice of code of this method
    // Hence if it is a complex type we are recursively calling TrimSpaces
    var customTypes =
    obj.GetType()
       .GetProperties(BindingFlags.Instance | BindingFlags.Public)
       .Where(prop => !prop.GetType().IsPrimitive && prop.GetType().IsClass && !prop.PropertyType.FullName.StartsWith("System"));
    
    foreach (var customType in customTypes.Where(customType => 
			customType.GetIndexParameters().Length == 0))
			customType.GetValue(obj).TrimSpaces();
    
    return obj;
```

This solution is available on [github](https://github.com/USaiPavan/BlogPostCode/tree/master/TrimSpacesRecursively) and can be used in any of the projects which require the capability of trimming of objects