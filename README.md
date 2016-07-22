# GraphIVR
## A Graph-based Interactive Voice Response (IVR) System

###Introduction

The application produces an interactive voice response (IVR) system based on a directed property graph.

###Requirements

* [BaseX](http://basex.org/)
* [Neo4j](https://neo4j.com/)
* [Twilio](https://www.twilio.com/)

###Installation


###Graph Model

GraphIVR allows you to configure your IVR by manipulating a Neo4j graph. For instance, a simple phone tree may be modelled in Neo4j as follows:

![Graph of a simple IVR](http://i.imgur.com/tuxl8va.png)

There are three type of nodes in the graph: Choice, Record, and Terminus. A Choice node presents callers with branching options in the graph. A Record node allows callers to record information. A Terminus node ends the call. There is only a single type of edge in the graph: Key. A Key edge allows callers to traverse from one node to the next based on a keypad entry. 

Choice nodes must have at least one Key edge. All the properties in the diagram below are required for Choice nodes and Key edges.

![Choice node with key edge](http://i.imgur.com/tuxl8va.png)
