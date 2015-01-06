# Unified Text Chat

## Welcome to the source repo for UTChat, UTLib and UText.
### We are currently moving from BitBucket to GitHub, so some links may be out of date.

**Quick Links**:

* [**Where to download**](https://github.com/alecxvs/UTChat/releases)
* [**How to install**](https://github.com/alecxvs/UTChat/wiki/UTChat%20for%20Server%20Operators)
* [**What to code**](https://github.com/alecxvs/UTChat/wiki/UText%20Developer's%20Guide)
* [**Compatibility**](https://github.com/alecxvs/UTChat/wiki/Compatibility%20with%20other%20modules)

---

More information on each module:

####**UTChat**, a stylistic chat replacement that comes prepackaged with UTLib, which includes a small but robust set of formats for modules to use.

> It contains a lot of room for developers to expand on by adding their own formats, setting up a chat handler to work with UTChat, or even disabling UTChat's player chat handling in favor of their own.

**UTChat** currently comes with the following addons:

* **Color**: allowing color to be arbitrarily applied to any part of a text
* **Shadow**: a convenient format for rendering shadow text behind the main text
* **Motion**: including an easing library, this allows text to move around with little effort
* **Fade**: also including the easing library, you can add easy fade in or fade outs to your text
* *Basic Tags*: a chat handler that applies any registered format. It looks for [<format>]text[/<format>], <format> being any registered format (in this list above, or any third-party formats)

---

**UText** is a script to benefit addons and modules. It is very powerful and easy to use. Using UText, you can create rendered text using simple methods and easy to read syntax. If you need proof just look at what UTChat can do with it, using UText is the simple part!

---

**UTLib** packages all modules that use UText within the same module together. It includes helper functions, utilities (such as formats for UText), and allows modules (internal and external) to register and declare dependencies so that they can load in a proper order.

---

## **For Server Admins**:
####**See [UTChat for Server Operators](https://bitbucket.org/SonicXVe/utlib/wiki/UTChat%20for%20Server%20Operators) for the details of UTChat**

---

## **For Developers**:
Reference the [Developer's Guide here](https://github.com/alecxvs/UTChat/wiki)

Each module in UTLib (UTChat, UTLib, UText) allow for different types of utilization -- work with the one that best suits what you want to do!

###Develop with UTChat if you want to:
* Apply formats to a chat message triggered by a key word or character (chat handler)
* Print text using UTChat by an internal or external module

###Develop with UTLib if you want to:
* Load UTLib modules in order based on dependency
* Utilize UText Deployment (not yet implemented)
* Reliably send commands between UTLib modules

###Develop with UText if you want to:
* Use robust text rendering without relying on a separate module (including utext.lua in your own module)
* Create new formats for use with UText (UTLib isn't required)
* Easy to use text creation
