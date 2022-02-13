# GMail-ATOM-Sensor

# Scope

This is a Luup plugin to check your GMail Atom feed for unread emails associated with specific custom labels

Luup (Lua-UPnP) is a software engine which incorporates Lua, a popular scripting language, and UPnP, the industry standard way to control devices. Luup is the basis of a number of home automation controllers e.g. Micasaverde Vera, Vera Home Control, OpenLuup.

# Compatibility

This plug-in has been tested on the Ezlo Vera Home Control system.
You need a Gmail account that is not set up for OAUTH, it will require some security settings turned off to just allow username/password access
Custom labels (e.g Vera) can be created and used - > https://hiverhq.com/blog/gmail-labels
System labels (e.g ^i) can be used too labels are here - > https://developers.google.com/gmail/android/com/google/android/gm/contentprovider/GmailContract.Labels.LabelCanonicalNames

** Don't use this for any sensitive information, i am just using it for generic alert messages, and the account name has no personally identifiable information

# Features

It supports the following functionality:

* Creation of a device in UI to show your unread email of a specific Gmail label
* Periodically updates the number of unread emails based on the 
* Multiple labels can be given, comma seperated, but only one displayed

Still to be added..

* Add a button to refresh labels on demand
* Add default variable to show other system label information
* other fixes/updates

# Imstallation / Usage

This installation assumes you are running the latest version of Vera software.

1. Upload the icon mail.png file to the appropriate storage location on your controller. For Vera that's `/www/cmh/skins/default/icons`
3. Upload the .xml and .json file in the repository to the appropriate storage location on your controller. For Vera that's via Apps/Develop Apps/Luup files/
4. Create the decice instance via the appropriate route. For Vera that's Apps/Develop Apps/Create Device/ and putting "D_GMailAtom1.xml" into the Upnp Device Filename box. 
5. Reload luup to establish the device and then reload luup again (just to be sure) and you should be good to go.

# Quick Configuration script

After you have added the files and created the device, the following is a quick way to configure the device, simply update the following and run it via Apps/Develop Apps/Test Code 

````
local DEVICE = 1194  -- Device ID assigned on Vera
local ATOM_SERV = "urn:nodecentral-net:serviceId:GMailAtom1"
local USERNAME = "your_email_address@gmail.com"
local PASSWORD = "your_password"
local CUSTOM_LABELS = "Vera, ^all, "  -- Label(s) to be checked
local DISPLAY_LABEL = "Vera"  -- Label of count you want to appear on the UI
luup.variable_set(ATOM_SERV, "USERNAME", USERNAME, DEVICE)
luup.variable_set(ATOM_SERV, "PASSWORD", PASSWORD, DEVICE)
luup.variable_set(ATOM_SERV, "CUSTOM_LABELS", CUSTOM_LABELS, DEVICE)
luup.variable_set(ATOM_SERV, "DISPLAY_LABEL", DISPLAY_LABEL, DEVICE)
luup.reload()
````

# Limitations

While it has been tested, it has not been tested very much and may not support other related devices or those running different firmware.

# Buy me a coffee

If you choose to use/customise or just like this plug-in, feel free to say thanks with a coffee or two.. 
(God knows I drank enough working on this :-)) 

<a href="https://www.paypal.me/nodezero" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

# Screenshots

Once installed, you should see the device listed with your display label

![D858216C-7C05-428A-8D6A-4F2D686D01FC](https://user-images.githubusercontent.com/4349292/153750124-7a404868-59d9-4228-b058-47889f0ba491.jpeg)

# License

Copyright © 2021 Chris Parker (nodecentral)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses
