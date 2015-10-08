$puppetserver = 'puppet'
#import "nodes/node.pp"
node 'client1.localdomain' {
    include ssh
    include apache
}
node 'client2.localdomain' {
    include ssh
    include apache
}
