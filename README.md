# GraphIVR
## A Graph-based Interactive Voice Response (IVR) System

###Introduction

The application operates an interactive voice response (IVR) system based on a directed property graph.

###Requirements

* [BaseX](http://basex.org/), an open-source XML database with a built-in HTTP server.
* [Neo4j](https://neo4j.com/), an open-source graph database.
* [Twilio](https://www.twilio.com/), a cloud-based communications company with support for voice calls.

###Installation

1. Download the [BaseX HTTP War](http://basex.org/products/download/) and upload it to either a Tomcat or Jetty server. If you need an easy way to host BaseX, you may want to try out Servint's [Jelastic PaaS](https://www.servint.net/product/jelastic/), which makes hosting Java applications very straightforward. After you install BaseX, make sure [to change the admin password](http://docs.basex.org/wiki/User_Management) and, if desired, update the [WebDav and REST passwords in the web.xml file](http://docs.basex.org/wiki/Web_Application#Configuration). You will also need to add support for `mixupdates` in the web.xml file by adding this XML snippet:

```xml
<context-param>
    <param-name>org.basex.mixupdates</param-name>
    <param-value>true</param-value>
</context-param>
```  

2. Provision a telephone number with Twilio. If you do not already have a Twilio account, you will need to create one. After you have created your account, click on [Buy a Number](https://www.twilio.com/console/phone-numbers/search) from the Twilio console. After you have provisioned the number, click on [Manage your Incoming Phone Numbers](https://www.twilio.com/console/phone-numbers/incoming) and select your new number. Set a web hook for your incoming voice calls to the base-url of your website + "/node"

![Creating a web hook with Twilio](http://i.imgur.com/IkXXUQa.png)


###Graph Model

GraphIVR allows you to configure your IVR by manipulating a Neo4j graph. For instance, a simple phone tree may be modelled in Neo4j as follows:

![Graph of a simple IVR](http://i.imgur.com/9OqkL2r.png)

There are three type of nodes in the graph: Choice, Record, and Terminus. A Choice node presents callers with branching options in the graph. A Record node allows callers to record information. A Terminus node ends the call. There is only a single type of edge in the graph: Key. A Key edge allows callers to traverse from one node to the next based on a keypad entry. 

Choice nodes must have at least one Key edge. The diagram below illustrates the available properties for Choice nodes and Key edges. The required properties for Choice nodes are "name," "say," and "id." The "play" property is optional. If a "play" property is present, GraphIVR will play the recorded sound at the indicated URL instead of speaking the phrases in the "say" property.

![Choice node with key edge](http://i.imgur.com/tuxl8va.png)

Record nodes must have one and only one Key edge. The edge should provide instructions about how to terminate the recording. The required properties of Record nodes are "name" and "id." A "say" or "voice" property should not be placed on Record nodes.

![Record node with key edge](http://i.imgur.com/okMLPD3.png)

Finally, a Terminus node ends the call. A terminus node must have only incoming edges and no outgoing Key edges. As with Choice edges, The required properties for Terminus nodes are "name," "say," and "id." The "play" property is optional. Normally, a Terminus edge should contain a message indicating that call will be coming to an end.

![Terminus node with incoming edge](http://i.imgur.com/nIPiUGM.png)
