# im_task
This package contains the @task function, for decorating python functions to be appengine tasks.

[![Build Status](https://travis-ci.org/emlynoregan/im_task.svg?branch=master)](https://travis-ci.org/emlynoregan/im_task)

This library is available as the package [im-task on pypi](https://pypi.org/project/im-task/).
 
## Install

Don't install this library directly; instead, you'll need to install one of the framework specific modules:

* [im_task_flask](https://github.com/emlynoregan/im_task_flask)
* [im_task_webapp2](https://github.com/emlynoregan/im_task_webapp2)

If you're using a different framework, and you'd like to use @task, let me know and I'll add support.

## @task

This decorator function is designed to be used as a replacement for [deferred](https://cloud.google.com/appengine/articles/deferred).

### Importing task

You can import task into your modules like this:

	from im_task import task
	
### Using task as a decorator

You can take any function and make it run in a separate task, like this:

	@task
	def myfunction():
	  ... do stuff ... 
  
Just call the function normally, eg:
 
	myfunction()

You can use @task on any function, including nested functions, recursive functions, recursive nested functions, the sky is the limit. This is possible because of use of [cloudpickle](https://github.com/cloudpipe/cloudpickle) as the underlying serialisation library.

Your function can also have arguments, including other functions:

	def myouterfunction(mapf):
	
	    @task
	    def myinnerfunction(objects):
	    	for object in objects:
	    	    mapf(object)
	    		
	    ...get some list of lists of objects... 
	    for objects in objectslist:
		myinnerfunction(objects)
			
	def dosomethingwithobject(object):
		... do something with an object ...		
	
	myouterfunction(dosomethingwithobject)
	
The functions and arguments are being serialised and deserialised for you behind the scenes.

When enqueuing a background task, the App Engine Task and TaskQueue libraries can take a set of parameters. You can pass these to the decorator:

	@task(queue="myqueue", countdown=5)
	def anotherfunction():
	  ... do stuff ... 

Details of the arguments allowed to Tasks are available [here](https://cloud.google.com/appengine/docs/python/refdocs/google.appengine.api.taskqueue), under **class google.appengine.api.taskqueue.Task(payload=None, \*\*kwargs)**. The task decorator supports a couple of extra ones, detailed below.

### Using task as a factory

You can also use task to decorate a function on the fly, like this:

	def somefunction(a, b):
	  ... does something ...
	  
    somefunctionintask = task(somefunction, queue="myqueue")

Then you can call the function returned by task when you are ready:

    somefunctionintask(1, 2)
    
You could do both of these steps at once, too:
  
  
    task(somefunction, queue="myqueue")(1, 2)
    
### transactional

Pass transactional=True to have your [task launch transactionally](https://cloud.google.com/appengine/docs/python/datastore/transactions#transactional_task_enqueuing). eg:

	@task(transactional=True)
	def myserioustransactionaltask():
	  ...
    
### includeheaders

If you'd like access to headers in your function (a dictionary of headers passed to your task, it's a web request after all), set includeheaders=True in your call to @task. You'll also need to accept the headers argument in your function.

	@task(includeheaders=True)
	def myfunctionwithheaders(amount, headers):
	    ... stuff ...
	    
	myfunctionwithheaders(10)
	
App Engine passes useful information to your task in headers, for example X-Appengine-TaskRetryCount.

### other bits

When using deferred, all your calls are logged as /_ah/queue/deferred. But @task uses a url of the form /_ah/task/\<module\>/\<function\>, eg:

	/_ah/task/mymodule/somefunction
	
which makes debugging a lot easier.


## Changing the default route
@task will use the route "_ah/task" by default. This is what needs to be handled in app.yaml. There's more info in the framework specific modules about this (see links above).

However, you may need to use a different route in some circumstances. If you do, you can just change the route like this:

	from im_task import set_taskroute
	
	set_taskroute(<my new route>)
	
Call that function early in your main.py, before @task is actually used anywhere, and remember that your configured route in app.yaml must match whatever route you provide here.

 
