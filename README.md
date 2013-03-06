KMWordPress
===========

KMWordPress is an example app that uses a JSON feed produced by the [JSON API plugin](http://wordpress.org/extend/plugins/json-api/) (you'll need to use my [fork](https://github.com/kmonaghan/wp-json-api) though) and displays it in a reasonable manner.

Currently, this example forms the basis for the [Broadsheet.ie](http://broadsheet.ie) [app](https://itunes.apple.com/ie/app/broadsheet.ie/id413093424?mt=8).  I've blogged about [how this version has improved](http://www.karlmonaghan.com/2013/03/01/broadsheet-ie-iphone-app-2-0/) over the [previous incarnation](https://github.com/kmonaghan/Broadsheet.ie-iOS).

## Getting Started
First you need to initialise all the submodules:
```
$ git submodule update --init --recursive
```

You'll also need the [Facebook SDK](https://github.com/facebook/facebook-ios-sdk) in the same folder you've cloned this project too (or manually change all the paths).

In [KMWordPressAPIClient.m](KMWordPress/blob/master/KMWordPress/Classes/KMWordPressAPIClient.m#L15) you need to change the base URL:
``` objective-c
static NSString * const kKMWordpressURLString =  @"http://www.broadsheet.ie/";
```

Open the project, compile it and you should see a feed of your posts.

You should change the app id used by Appirater and put in your own Google Analytics tracker before you distribute it to anyone.

### Icons
The icons used the live version of the app are from [Glyphish](http://www.glyphish.com/) so I can't distribute them.  I've replaced them with some free ones from [TWG](http://blog.twg.ca/2010/11/retina-display-icon-set/twg_retina_icons/) and [Gentleface](http://gentleface.com/free_icon_set.html) but kept the Glyphish icon names so you can drop them in if you want.

## Requirements

KMWordPress requires [iOS 5.0](http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniOS/Articles/iOS5.html) and above.

### ARC
KMWordPress uses ARC.

## Creator

[Karl Monaghan](http://github.com/kmonaghan)  
[@karlmonaghan](https://twitter.com/karlmonaghan)

## License

KMWordPress is available under the MIT license. See the LICENSE file for more info.
