ssh_key_path = "/home/vboxuser/MYKEY.pub"

service_account = {
    bucket_account={
        name = "bucketsa"
        desc = "base bucket"
        role = "editor"
    }
}

kms_key = {
    key_a={
        name="first_key"
        desc="base kms key"
        default_algorithm = "AES_256"
        rotation_period   = "168h"
    }
}

sa_key_desc = "base service account key"

test_bucket_name = "testbucketwithkms"