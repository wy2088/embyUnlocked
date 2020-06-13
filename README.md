# EmbyUnlocked

## Introduction

Emby was free and developed under community, but there is a day they decided to invok there code into private status. There are some informations here: [Learn More](https://github.com/nvllsvm/emby-unlocked)

> Update 2019-01-17 - The Emby team has deleted the relevant GitHub isuses in an attempt to hide community backlash. Below are archived versions of those issues:
>
> [Issue 3075 - GPL Violation](https://web.archive.org/web/20181212044938/https://github.com/MediaBrowser/Emby/issues/3075)
>
> [Issue 3479 - Source Code Missing (Going Proprietary)](https://web.archive.org/web/20181212100152/https://github.com/MediaBrowser/Emby/issues/3479)

## Result

![Example Result](./example.png)

## Instructions - Server

Find some where safe to download our git repo

    git clone https://github.com/Co2333/embyUnlocked
    cd embyUnlocked

Modify the docker-compose.yml as you want

> See [LinuxServer/emby](https://github.com/linuxserver/docker-emby/) for configuration information

    nano ./docker-compose.yml
    docker-compose up --build

After build, run following command for maintain purpose

    docker-compose kill
    docker-compose up -d

## Instructions - Client

After the first start up, you will have your unlocked emby container image. Input any key will work. But this is not enough for unlock all feature because server activations and client activations are isolated between each of each.

#### You Are On Your Own To Unlock Client Features

#### Example - Using [Surge](nssurge.com)

Coming Soon

## License 

```
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Ihave Noname <idonthaveanemail@dowtf.com>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```

2020.6.13 by [Ihave Noname]