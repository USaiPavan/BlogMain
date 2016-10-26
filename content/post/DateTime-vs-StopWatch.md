+++
title = "DateTime vs. StopWatch"
draft = false
date = "2012-01-03T09:00:00-05:00"
Tags = ["C#"]

+++

Today I was trying to measure performance of an extension method that I have written on a DataSet. Basically, the extension method loops through all the DataTables. On each  DataTable it iterates through all the rows (including the column names) and encodes all the strings using the HttpUtility.HtmlEncode method. This is to make sure that we are protecting our site from XSS attack (more about prevention of XSS attacks in ASP.NET are [here](https://msdn.microsoft.com/en-us/library/ff649310.aspx)). I had to do this without effecting the current performance of the website.

Now, I had to somehow measure and I was using Debug.WriteLine method to log the details. First off I started with DateTime.Now, storing it in a variable and then after the processing was done subtracting it from the current DateTime (DateTime.Now) and taking the milliseconds elapsed in the resulting TimeSpan surprised me. I was sure that there was time consumption for that task but the output window was showing zero milliseconds. After couple of tries I resorted to StopWatch class. The usual Start and Stop methods before and after the task were now actually showing me the correct details. It was accurate to the Tick.

So my today’s learning, for accuracy and performance measurements depend only on StopWatch class :-). Might have learned it late but as the saying goes “Better late than never”. Hope it helps some one.