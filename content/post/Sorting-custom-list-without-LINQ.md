+++
title = "Sorting a custom list without LINQ"
draft = false
date = "2015-10-09T09:00:00-05:00"
Tags = ["CSharp", "LINQ"]

+++

As much as we want to work on latest and greatest technologies sometimes we end up working on older technologies. This becomes especially tough when we have already worked on latest technologies. One such examples is LINQ.

LINQ has made life of developers so easy that it feels wierd how we used to do stuff like filtering and other actions on collections without using LINQ. Recently I came across a scenario where I had to sort a custom type list based on varoius properties in it. However, I was working on .Net 2.0 and as we all know we didn't have LINQ back then. Hence I was stuck with using whatever was available in .Net 2.0

There were quite a few options before me but I chose the simplest one which is using *Array.Sort()* method which is *aware* of sorting all the primitive data types. Luckily my custom type was made up of primitive data types

So here is the code that I have written to be able to achieve that feat..

First my custom type (obviously different from what I have worked on but is similar)

```csharp
class TrainingEmployee
{
    public int Count { get; set; }        
    public string TrainingTypeName { get; set; }
    public string LocationName { get; set; }
    public string DueStatus { get; set; }
    public string EmployeeNumber { get; set; }
    public string EmployeeName { get; set; }                
}
```
Now easier way to sort the custom type list

```csharp
public void BuildAndSortEmployees()
{
    List<TrainingEmployee> employees = new List<TrainingEmployee>();
    employees.Add(new TrainingEmployee
    {
        Count = 10,
        DueStatus = "Due",
        EmployeeName = "Tom",
        EmployeeNumber = "2",
        LocationName = "Hogwarts",
        TrainingTypeName = "bca"
    });
    employees.Add(new TrainingEmployee
    {
        Count = 5,
        DueStatus = "Due",
        EmployeeName = "Riddle",
        EmployeeNumber = "12",
        LocationName = "DiagonAlley",
        TrainingTypeName = "bca"
    });
    employees.Add(new TrainingEmployee
    {
        Count = 8,
        DueStatus = "Due",
        EmployeeName = "Lord",
        EmployeeNumber = "22",
        LocationName = "PrivetDrive",
        TrainingTypeName = "bca"
    });
    employees.Add(new TrainingEmployee
    {
        Count = 12,
        DueStatus = "Due",
        EmployeeName = "Voldemort",
        EmployeeNumber = "8",
        LocationName = "TestLocation",
        TrainingTypeName = "bca"
    });

    employees.Sort((x, y) =>
    {
        var ret = x.EmployeeName.CompareTo(y.EmployeeName);
        return ret;
    });
}
```

The *EmployeeName* property can be literally be replaced with any of the properties in the TrainingEmployee class and the sort just works. Here we are using the Array.Sort and also using the [CompareTo](https://msdn.microsoft.com/en-us/library/system.icomparable.compareto(v=vs.110).aspx) we are comparing the primitive data types. This won't work out of the box for custom data types, if any, in *TrainingEmployee* class but requires a EqualityComparer implementation of the custom data type

That is it. It is a short post on how to do sorting of custom types without using LINQ