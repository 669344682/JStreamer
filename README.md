# JStreamer

### how to use

- Download JStreamer master
- Extract the folder 'JStreamer' into your MTA resources
- Start JStreamer then map associated with it.

# Formatting

### JSD
`identity(nickname),dff,txd,coll,drawdistance(0-300),alpha(boolean),cull(boolean),assignlod(boolean)`

#### Example
`ugoeast_zem294,ugoeast_zem294,southland,ugoeast_zem294,290,nil,nil,true`

### JSP
###### Line 1
`Xoffset,Yoffset,Zoffset`
###### Other Lines

`identity(nickname),interior,dimension,x,y,z,xr,yr,zr`

#### Example
`gados_p3a,0,-1,2060,1376,17,0,0,90`

# Folder Structure
```
gta3.JSD (Element Definitions)
gta3.JSP (Element Locations)
```
## Content

### coll (COLL dictonary)
`item.coll`
### models (DFF dictonary)
`item.dff`
### textures (TXD dictonary)
`item.txd`

## Loaders
```
JSDLoader.lua (Defintion loader)
JSPLoader.lua (Object loader)
```
## Settings

`CWaterData.lua (Water Data)`


[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/BlueJayL)
