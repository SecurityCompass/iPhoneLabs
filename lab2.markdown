---
layout: default
title: Lab 2 - Parameter manipulation
---

## {{ page.title }}

### Lab 

The parameter manipulation lab is contained within the bank transfer section.

The purpose of this lab is to demonstrate that many common iPhone
applications still rely on traditional web architectures or REST
interfaces in the back end to perform their tasks.  Often, if you're
able to trap the request, you can make the application or server act
in ways it may not have felt possible.

First, enter the bank money transfer screen within the ExploitMe Mobile app.
![transfer screen](img/2_transferscreen.jpeg)

There are a number of accounts preconfigured in EMM's default Lab
server configuration.  We've logged in before using the jdoe account.
The two usernames we have preconfigured and their bank account numbers
are:

1. jdoe / password
  * Debit: 123456789
  * Credit: 987654321
1. bsmith / password
  * Debit: 111111111
  * Credit: 22222222 

In this lab, we'll try to transfer money between accounts on the
server by intercepting the EMM app request.  Again, this traditionally
isn't any different from web exploits, but most apps work in the same
manner so it'll be good to see how it works on the mobile app space.

Fill in the transfer screen and ensure your proxy is trapping the request.

![Transfer](img/2_transfer.jpeg)

We'll transfer $50 between our accounts.  Hit the transfer button and trap the request.

![Trapping transfer](img/2_trap_orig.jpeg)

You can see that the app is sending the request to the web server
through a standard HTTP POST.  Often with these mobile applications
they will either be POSTs with a session key or a Web service XML
request.

We can now modify the "from_account" field to see if we can transfer from another account into our own!

![Modifying transfer](img/2_trap.jpeg)

Notice that the from account is now from another user.

## Solution

The solution here is the same as it would be in a regular web app, we
have to perform some validation on the server.  You can see how it is
done in the ParameterManipulationSolution branch of the server source,
available
[here](https://github.com/SecurityCompass/LabServer/tree/ParameterManipulationSolution).

{% highlight python %}
#validate that accounts belong to user:
if to_account.user != session.user or from_account.user != session.user:
    return error("E6")

#validate that amount is positive
if total_cents < 0:
    return error("E5")
{% endhighlight %}
