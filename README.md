# SaidIt

[SaidIt](https://saidit.net) is a continuation and fork of [reddit open source](https://github.com/reddit-archive/reddit) which was [sunset](https://www.reddit.com/r/changelog/comments/6xfyfg/an_update_on_the_state_of_the_redditreddit_and/) in 2017. SaidIt changes include:

* Two dimensional voting where insightful is +2 and funny is +1
* Public moderator logs
* More embedded media
* IRC integration with [TheLounge](https://github.com/libertysoft3/lounge-autoconnect) web client
* Configurable site branding
* Admin tools restored: global user ban, ip ban
* Bug fixes, critical configuration and cron jobs restored
* Ubuntu 18 support

SaidIt changes can be disabled and/or reverted in your fork to provide a vanilla reddit experience. Additionally, the SaidIt team is happy to help create an updated reddit-only fork with the traditional reddit voting model, etc.

---

## Installation

### Optional: create a Ubuntu virtual machine

1. Download [Ubuntu Server 18.04.2 LTS](https://www.ubuntu.com/download/server)
1. Install and run [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (free and supports Linux, Mac, or Windows)
1. Creating a new Linux virtual machine with 30gb+ disk space
1. In Settings -> System set Base Memory to 4gb+ RAM and Processors to 4+
1. In Settings -> Storage fill the optical drive by clicking "Choose Virtual Optical Disk File" and selecting the Ubuntu 18 .iso from step 1
1. In Settings -> Network for Adapter 1, select "Attached to: Bridged Adapter"
1. Start the VM (Normal or Detachable)
1. Proceed through Ubuntu installation by choosing the default options
1. Your server's name: ubuntu-vm
1. Pick a username: reddit
1. Select "Install OpenSSH server"
1. Choose "Reboot Now", press enter if prompted, login
1. If you forgot to install the OpenSSH server, run:
  1. `$ sudo apt-get update`
  1. `$ sudo apt-get upgrade`
  1. `$ sudo apt-get install openssh-server`
1. Run `$ ifconfig` and note your VM's ip address

You can now detach your VM or shut it down and restart it in headless mode, to interact with the VM via SSH instead, with your normal terminal. Don't forget to shut down your VM before shutting down your host/desktop OS.

### Install SaidIt/reddit open source

SSH into your server or VM to install. This documentation assumes you connect as user 'reddit' with sudo privileges.

    $ ssh reddit@UBUNTU-18-IP
    $ sudo apt-get update
    $ sudo apt-get upgrade
    $ sudo apt-get install git
    $ cd ~/
    $ git clone https://github.com/libertysoft3/saidit.git
    $ chmod +x saidit/install-reddit.sh
    # on a production server with a domain name run:
    $ sudo REDDIT_DOMAIN=example.com ./saidit/install/reddit.sh
    # otherwise run:
    $ sudo ./saidit/install-reddit.sh
    # cleanup
    $ rm -rf ~/saidit
    $ ls -la ~/src/reddit

    ??
    # if you get an error about "less" restart the server and try again






### Upgrade curl

this will improve the new link 'fetch title' capability and potentially more

    $ sudo apt-get build-dep curl
    # use latest version from https://curl.haxx.se/download.html:
    $ wget http://curl.haxx.se/download/curl-7.64.0.tar.bz2
    $ tar -xvjf curl-7.64.0.tar.bz2
    $ cd curl-7.64.0
    $ ./configure --prefix=/usr
    $ make
    $ sudo make install
    $ sudo ldconfig
    $ curl --version
 
 
### Upgrade to python 2.7
 
    $ sudo add-apt-repository ppa:jonathonf/python-2.7
    $ sudo apt-get update
    $ sudo apt-get install python2.7
    $ python --version

### Upgrade gcc

    $ sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    $ sudo apt-get update
    $ sudo apt-get install gcc-4.9 g++-4.9 cpp-4.9
    $ cd /usr/bin
    $ sudo rm gcc g++ cpp x86_64-linux-gnu-gcc
    $ sudo ln -s gcc-4.9 gcc
    $ sudo ln -s g++-4.9 g++
    $ sudo ln -s cpp-4.9 cpp
    $ sudo ln -s x86_64-linux-gnu-gcc-4.9 x86_64-linux-gnu-gcc

### Rebuild reddit
 
    $ sudo reddit-stop
    $ sudo reddit-flush
    $ sudo apt-get install libxml2-dev libxslt1-dev python-dev
    $ cd ~/src/reddit/r2
    $ python setup.py build
    $ sudo python setup.py develop
    $ make clean
    $ make
    $ sudo reddit-start






### Install sample data

`inject_test_data()` also creates an admin user "saidit" with password "password" if the user doesn't exist.

    $ cd ~/src/reddit
    $ reddit-run scripts/inject_test_data.py -c 'inject_test_data()'
    $ sudo reddit-restart

---

## Install Solr for search
 
Install Solr

    $ cd ~
    $ sudo apt-get install tomcat7 tomcat7-admin software-properties-common
    $ wget http://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.tgz
    $ tar -xvzf solr-4.10.4.tgz
    $ sudo mv solr-4.10.4 /usr/share/solr
    $ sudo chown -R tomcat7:tomcat7 /usr/share/solr/example
 
Setup Solr, install Reddit schema

    $ sudo cp /usr/share/solr/example/webapps/solr.war /usr/share/solr/example/solr/
    $ sudo cp /usr/share/solr/example/lib/ext/* /usr/share/tomcat7/lib/
    $ sudo cp /usr/share/solr/example/resources/log4j.properties /usr/share/tomcat7/lib/
    $ sudo cp src/reddit/solr/schema4.xml /usr/share/solr/example/solr/collection1/conf/schema.xml
    $ sudo chown tomcat7:tomcat7 /usr/share/solr/example/solr/collection1/conf/schema.xml
 
Setup Tomcat for Solr

    $ sudo nano /usr/share/tomcat7/lib/log4j.properties
    # edit to set:
    solr.log=/usr/share/solr
 
    $ sudo nano /etc/tomcat7/Catalina/localhost/solr.xml
    # add content:
    <Context docBase="/usr/share/solr/example/solr/solr.war" debug="0" crossContext="true">
      <Environment name="solr/home" type="java.lang.String" value="/usr/share/solr/example/solr" override="true" />
    </Context>
 
    # have tomcat use port 8983, 8080 is taken by haproxy
    sudo nano /etc/tomcat7/server.xml
    # edit to set:
    <Connector port="8983" protocol="HTTP/1.1"
 
    # Solr is missing some required stuff:
    $ sudo touch /usr/share/solr/solr.log
    $ sudo mkdir /usr/share/tomcat7/temp
    $ sudo chown tomcat7:tomcat7 /usr/share/solr/solr.log
    $ sudo chown tomcat7:tomcat7 /usr/share/tomcat7/temp
 
    # verify tomcat all good (ignore warnings):
    $ /usr/share/tomcat7/bin/configtest.sh

Start solr:

    $ sudo service tomcat7 restart
    # any errors in here must be fixed
    $ sudo cat /var/log/tomcat7/catalina.out
    # verify working, these should return html pages:
    $ wget 127.0.0.1:8983
    $ wget 127.0.0.1:8983/solr
 
### Configure reddit to use Solr for search:

Add the following to `~/src/reddit/r2/development.update` to the default section. NOTE: solr port changed from default 8080 to 8983.

    search_provider = solr
    solr_version = 4
    solr_search_host = 127.0.0.1
    solr_doc_host = 127.0.0.1
    solr_subreddit_search_host = 127.0.0.1
    solr_subreddit_doc_host = 127.0.0.1
    solr_port = 8983
    solr_core = collection1
    solr_min_batch = 500
    solr_query_parser =
 
Since reddit config has changed:

    $ cd ~/src/reddit/r2
    $ make ini
    $ sudo reddit-restart
 
### Add reddit content to Solr, verify working:

    $ cd ~/src/reddit/r2
    $ paster run run.ini -c 'import r2.lib.providers.search.solr as cs; cs.rebuild_subreddit_index()'
    $ paster run run.ini -c 'import r2.lib.providers.search.solr as cs; cs._rebuild_link_index()'
 
 
### Setup Solr cron jobs:
 
    $ sudo nano /etc/init/reddit-job-solr_subreddits.conf
    # paste lines, save:
    description "Add new subreddits to Solr."
    manual
    task
    stop on reddit-stop or runlevel [016]
    nice 10
    script
        . /etc/default/reddit
        wrap-job paster run $REDDIT_INI -c 'import r2.lib.providers.search.solr as cs; cs.rebuild_subreddit_index()'
    end script
 
and then...
 
    $ sudo nano /etc/init/reddit-job-solr_links.conf
    # paste lines, save:
    description "Add new posts to Solr."
    manual
    task
    stop on reddit-stop or runlevel [016]
    nice 10
    script
        . /etc/default/reddit
        wrap-job paster run $REDDIT_INI -c 'import r2.lib.providers.search.solr as cs; cs._rebuild_link_index()'
    end script
 
 TODO: assume Solr will be installed, add these two jobs to the codebase, configure solr in example.ini.

---

## Install SaidIt Chat

In a production environments, irc and related services should be run by a dedicated unix user for security.

### Install unreal irc server

    $ sudo apt-get install make gcc build-essential openssl libssl-dev libcurl4-openssl-dev zlib1g zlib1g-dev zlibc libgcrypt11 libgcrypt11-dev
    # UPDATE to the latest stable release
    $ wget https://www.unrealircd.org/unrealircd4/unrealircd-4.2.0.tar.gz
    $ tar xzvf unrealircd-4.2.0.tar.gz
    $ cd unrealircd-4.2.0/
    $ ./Config
    # space to read the license, press [Enter] a bunch of times to install, for "Do you want to generate an SSL certificate for the IRCd?" respond "No"
    $ make
    $ make install

use the reddit.local SSL cert with unreal:

    $ sudo cp /etc/ssl/certs/ssl-cert-snakeoil.pem ~/unrealircd/conf/ssl/server.cert.pem
    $ sudo cp /etc/ssl/private/ssl-cert-snakeoil.key ~/unrealircd/conf/ssl/server.key.pem
    # assuming you are installing as user 'reddit':
    $ sudo chown reddit:reddit ~/unrealircd/conf/ssl/*

configure unreal:

    $ cd ~/unrealircd
    $ cp conf/examples/example.conf conf/unrealircd.conf
    # edit conf/unrealircd.conf and change:
    #   change 'oper bobsmith' to `oper ircoperator`
    #   change 'password "test";' to a unique password
    #   section 'cloak-keys' needs 2 keys added
    #   set 'kline-address' to an email address
    #   set 'maxchannelsperuser' t0 50
    #   in 'allow' block for ip '*@*' change 'maxperip' to 10
    #   add a new allow block: allow { ip *@127.0.0.1; class clients; maxperip 50000; };

configure unreal for anope services. add the following to `~/unrealircd/conf/unrealircd.conf`, before `ulines`:

    link services.reddit.local
    {
        incoming {
                mask *@127.0.0.1;
        };
        outgoing {
                bind-ip *; /* or explicitly an IP */
                hostname services.reddit.local;
                port 6900;
                options { ssl; };
        };
        password "my-services-password-1234";
        class servers;
    };

change `ulines` to:

    ulines {
      services.reddit.local;
    };

start unreal:

    $ ./unrealircd start

cleanup, substitute your version number where appropriate:

    $ cd ~
    $ rm -rf unrealircd-4.2.0
    $ rm unrealircd-4.2.0.tar.gz

### Install anope IRC services

This provides ListServ, ChanServ, etc.

    $ cd ~
    $ sudo apt-get install cmake build-essential
    # update version number to the latest stable release:
    $ wget https://github.com/anope/anope/releases/download/2.0.6/anope-2.0.6-source.tar.gz
    $ tar xzvf anope-2.0.6-source.tar.gz
    $ cd anope-2.0.6-source
    $ ./Config
    # press [Enter] a bunch, accept defaults
    $ cd build/
    $ make
    $ make install

Configure anope:

    $ cd ~/services/conf/
    $ cp nickserv.example.conf nickserv.conf
    # edit nickserv.conf, set guestnickprefix = "guest" (for The Lounge autconnect feature)
    $ cp operserv.example.conf operserv.conf
    # NOTE: insecure if you allow outside access to IRC/6667, instead just change maxsessionlimit only and later run:
    #    /msg OperServ exception add +0 127.0.0.1 50000 Allow many localhost TheLounge clients
    # edit operserv.conf, set defaultsessionlimit = 50000, maxsessionlimit = 50000 (since everyone connects from localhost)
    $ cp example.conf services.conf
    # edit services.conf and set:
    # set uplink::ssl to 'yes'
    # set uplink::port to 6667
    # set uplink::password to 'my-services-password-1234'
    # set serverinfo::name to services.reddit.local
    # comment out the botserv include, search for `botserv.example.conf`
    # change `nickserv.example.conf` to `nickserv.conf`
    # change `operserv.example.conf` to `operserv.conf`
    # change `inspircd20` (in `module`) to `unreal4`

add this oper section near the existing disabled ones:

    oper
    {
        name = "ircoperator"
        type = "Services Root"
        require_oper = yes
    }

start anope:

    $ cd ~/services/bin
    $ ./services

cleanup, substitute your version number where appropriate:

    $ cd ~
    $ rm -rf anope-2.0.6-source
    $ rm anope-2.0.6-source.tar.gz

### Install TheLounge web IRC client

    $ cd ~
    $ git clone https://github.com/libertysoft3/lounge-autoconnect.git
    $ cd lounge-autoconnect
    # update to the latest autoconnect branch
    $ git checkout v2.4.0-autoconnect
    $ npm install
    $ NODE_ENV=production npm run build
    $ node index config
    # [ESC] : q to quit

configure TheLounge, SSL cert paths may need to be adjusted:

    $ nano ~/.lounge/config.js
    # edit to match:
    #   public: false,
    #   port: 2053,
    #   theme: "themes/zenburn.css",
    #   prefetch: true,
    #   prefetchStorage: true,
    #   prefetchMaxImageSize: 2048,
    #   lockNetwork: true,
    #   defaults { name: "saiditDEV", host: "127.0.0.1", nick: "guest", username: "guest", realname: "Guest", join: "#home" }
    #   https: { enable: true, key: "/home/reddit/unrealircd/conf/ssl/server.key.pem", certificate: "/etc/ssl/certs/ssl-cert-snakeoil.pem" }

add an intial user so the server will start:

    $ cd ~/lounge-autoconnect
    $ node index add firstuser
    # use a throwaway password, don't log to disk

start TheLounge:

    $ cd ~/lounge-autoconnect
    $ nohup npm start ./ > thelounge.log 2>&1 &

---

## SaidIt dev guide

To interact with your site via https://reddit.local rather than your server or VM's ip address, edit `/etc/hosts` and add something like `192.168.1.20 reddit.local`. This procedure [varies by OS](https://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/).

watch saidit/reddit open source run, view errors

    $ sudo tail -f /var/log/syslog

You can mount the VM's reddit files as a folder on your host machine for easy editing and searching. On your host install sshfs and run `$ sshfs reddit@reddit.local:/home/reddit/src/reddit ~/vm`. Unmount it before shutting down your VM later with `$ fusermount -u ~/vm` to avoid crashing your editor when your VM shuts down.

change the default subs:

    $ cd ~/src/reddit/r2
    $ paster shell run.ini
    # paste the following, hit enter:
    from r2.models import *
    srs = [Subreddit._by_name(n) for n in ("pics", "videos", "science", "technology")]
    LocalizedDefaultSubreddits.set_global_srs(srs)
    LocalizedFeaturedSubreddits.set_global_srs([Subreddit._by_name('pics')])
    exit()

---

## Additional documentation

* [https://github.com/reddit-archive/reddit/wiki](https://github.com/reddit-archive/reddit/wiki)
* [https://www.reddit.com/r/RedditOpenSource](https://www.reddit.com/r/RedditOpenSource)
* [https://www.reddit.com/r/redditdev](https://www.reddit.com/r/redditdev)

---

## See also

* https://www.reddit.com/r/RedditAlternatives


