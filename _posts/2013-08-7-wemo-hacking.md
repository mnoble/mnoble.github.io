---
layout: post
title: WeMo Hacking
date: 2013-08-07
---

I recently got my hands on a Belkin WeMo and decided to put together a
web based version of their control panel. For the unaware, the device is
just essentially an outlet you can control via UPnP. "Control" mostly
means turning it on and off.

## Finding Devices

You can find all the devices currently connected to your network using
this library: [https://github.com/turboladen/upnp](https://github.com/turboladen/upnp)

{% highlight ruby %}
UPnP::SSDP.search("urn:Belkin:device:controllee:1")
{% endhighlight %}

You'll get back a list of Belkin devices and more importantly, their ip
address. That's found in the `:location` attribute.

## Services

You can use that `:location` from above to get all the services
available, but we're just going to talk about the one we really care
about, `basicevent`.

It's located at `/upnp/control/basicevent1` and has an identifier of 
`urn:Belkin:service:basicevent:1`. The identifier becomes relevant when 
constructing actions.

## Actions

Each Service exposes a bunch of actions. Since this is SOAP, an action
is basically a method. The two we care about are `GetBinaryState` and
`SetBinaryState`.

Binary State is how the WeMo describes whether it's on or off. 1 means
on and 0 means off &mdash; makes sense.

### GetBinaryState <small>Is the WeMo on or off?</small>

{% highlight bash %}
> POST http://10.0.0.11:49153/upnp/control/basicevent1 HTTP/1.1
> Content-type: text/xml; charset="utf-8"
> SOAPACTION: "urn:Belkin:service:basicevent:1#GetBinaryState"
{% endhighlight %}

{% highlight xml %}
<!-- Request body -->
<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"></u:GetBinaryState>
  </s:Body>
</s:Envelope>

<!-- Response body -->
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
   <u:GetBinaryStateResponse xmlns:u="urn:Belkin:service:basicevent:1">
     <BinaryState>0</BinaryState>
   </u:GetBinaryStateResponse>
 </s:Body>
</s:Envelope>
{% endhighlight %}

### SetBinaryState <small>Turning the WeMo on and off</small>

{% highlight bash %}
> POST http://10.0.0.11:49153/upnp/control/basicevent1 HTTP/1.1
> Content-type: text/xml; charset="utf-8"
> SOAPACTION: "urn:Belkin:service:basicevent:1#SetBinaryState"
{% endhighlight %}

{% highlight xml %}
<!-- Request body -->
<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1">
      <BinaryState>1</BinaryState>
    </u:SetBinaryState>
  </s:Body>
</s:Envelope>
{% endhighlight %}

## Wrapup

Controlling the device is actually pretty easy once you've discovered
the various services, actions and XML formats. The problem is that none
of it's documented and there aren't any WSDLs. You just have to play around 
with the services, inspect the XML you get back, etc.

If you don't want to deal with all of this, you're in luck! I've
abstracted most of this into a sort of framework. It's just sitting in a
little Sinatra app I wrote to control multiple WeMos. Extending it to
use more services is pretty straight-forward.

[https://github.com/mnoble/wemo/tree/master/lib](https://github.com/mnoble/wemo/tree/master/lib)
