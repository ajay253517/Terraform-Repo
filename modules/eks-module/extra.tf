resource "null_resource" "copy_kubeconfig" {
 provisioner "local-exec" {
   command = "cp ${module.eks.kubeconfig_filename} ~/.kube/config"
 }
}

