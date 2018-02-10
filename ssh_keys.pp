ssh_authorized_key { "master_root" :
        key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCeL/G+CK3T+Qgp2GQE1zhsHO1VXEN9lCwI6i+3UCu2lxIxv59JpgIWXvv2X/hcdRxCgxJB4EcJt/Dd/7A00GJoMNVA5gOoGncqljl0W28FL7in1ac65pNFLve5o1F8CKHdeKAei7UCIuOlDtH8cf0j9kfFNelhbBOG0oG7lBL2Bb+ee5J8kNzRyHspGzVVW942Q8BII3bCFtbfp9sV3Vo0PK6t8lBAsxgb789ugcEoZoZ2JR7k8Skp2cA2hztybixQwsNNxSPE541CH+yaM1JkcCFHtD3Vn8xJXNE4QpMsgOJ+UCJWeiLu1qYhiw2j9X6wPdrvuky+mZCyi4DX3bab",        
	user => root,
        ensure => present,
        type => rsa,
}

ssh_authorized_key { "master_ubuntu" :
        key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCeL/G+CK3T+Qgp2GQE1zhsHO1VXEN9lCwI6i+3UCu2lxIxv59JpgIWXvv2X/hcdRxCgxJB4EcJt/Dd/7A00GJoMNVA5gOoGncqljl0W28FL7in1ac65pNFLve5o1F8CKHdeKAei7UCIuOlDtH8cf0j9kfFNelhbBOG0oG7lBL2Bb+ee5J8kNzRyHspGzVVW942Q8BII3bCFtbfp9sV3Vo0PK6t8lBAsxgb789ugcEoZoZ2JR7k8Skp2cA2hztybixQwsNNxSPE541CH+yaM1JkcCFHtD3Vn8xJXNE4QpMsgOJ+UCJWeiLu1qYhiw2j9X6wPdrvuky+mZCyi4DX3bab",        
	user => ubuntu,
        ensure => present,
        type => rsa,
}

ssh_authorized_key { "bkup_ubuntu" :
        key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCoohJXltpLwD8p/aeomDqo9MZzGuPvHfJjEvKMyjgL8HYKsbpaC1BFOwxDijzSY8buokbdXbed7t4ZIS/bVXI7UW1bolIYa++LOGadVhkbnm0/NBCqlS7nyZ7HiNpiHasTp67FZkH7u+BZSVqU5iQmtSdJ/L9wLnrFS/IqUwmtQovF0RTVNNxgBVhAiMVFCsTRFshBmm7sBQ3floPRgfTuqbYO8F83Nt9fZA87TjXAEBJgU96p3+ugvU4ZlPAfbaqNg6gd3xbT64s/cvf7f/mkykfNuhZsjZv60WLIX5x7komORkU10i1MeT/4CKR+jkgtX6fwj/6y7/MtNi6aCgij",        
	user => ubuntu,
        ensure => present,
        type => rsa,
}
