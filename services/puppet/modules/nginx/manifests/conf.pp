class nginx::conf { 
    define nginx::vhost($port,$hostname,$rootdir,$filename=$title){ 
    file {"/etc/nginx/conf.d": 
        ensure => directory, 
        owner => "root", 
        group => "root", 
        mode => "744", 
        recurse => true, 
        require => Class["nginx::install"], 
    } 
    file {"$filename": 
        owner => "root", 
        group => "root", 
        mode => "644", 
        path => "/etc/nginx/conf.d/${filename}", 
        content => template("nginx/vhost.erb"), 
        require => File["/etc/nginx/conf.d"], 
    } 
}

nginx::vhost{"www.puppet.com.conf": 
    port => "80", 
    hostname => "www.puppet.com", 
    rootdir => "/var/www/puppet", 
    } 
}