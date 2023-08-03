resource "shoreline_notebook" "kubernetes_failed_persistent_volume_claims" {
  name       = "kubernetes_failed_persistent_volume_claims"
  data       = file("${path.module}/data/kubernetes_failed_persistent_volume_claims.json")
  depends_on = [shoreline_action.invoke_pvc_check,shoreline_action.invoke_get_storage_class,shoreline_action.invoke_sprov_check,shoreline_action.invoke_delete_pvc]
}

resource "shoreline_file" "pvc_check" {
  name             = "pvc_check"
  input_file       = "${path.module}/data/pvc_check.sh"
  md5              = filemd5("${path.module}/data/pvc_check.sh")
  description      = "Check for misconfiguration in the Persistent Volume Claims (PVCs) setting"
  destination_path = "/agent/scripts/pvc_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "get_storage_class" {
  name             = "get_storage_class"
  input_file       = "${path.module}/data/get_storage_class.sh"
  md5              = filemd5("${path.module}/data/get_storage_class.sh")
  description      = "Check the storage class and ensure that it is correctly configured and able to provide the requested storage."
  destination_path = "/agent/scripts/get_storage_class.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "sprov_check" {
  name             = "sprov_check"
  input_file       = "${path.module}/data/sprov_check.sh"
  md5              = filemd5("${path.module}/data/sprov_check.sh")
  description      = "Check the storage provisioner and ensure that it is correctly configured and running."
  destination_path = "/agent/scripts/sprov_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "delete_pvc" {
  name             = "delete_pvc"
  input_file       = "${path.module}/data/delete_pvc.sh"
  md5              = filemd5("${path.module}/data/delete_pvc.sh")
  description      = "Recreates Failed Persistent Volume Claims."
  destination_path = "/agent/scripts/delete_pvc.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pvc_check" {
  name        = "invoke_pvc_check"
  description = "Check for misconfiguration in the Persistent Volume Claims (PVCs) setting"
  command     = "`chmod +x /agent/scripts/pvc_check.sh && /agent/scripts/pvc_check.sh`"
  params      = ["PVC_NAME","NAMESPACE"]
  file_deps   = ["pvc_check"]
  enabled     = true
  depends_on  = [shoreline_file.pvc_check]
}

resource "shoreline_action" "invoke_get_storage_class" {
  name        = "invoke_get_storage_class"
  description = "Check the storage class and ensure that it is correctly configured and able to provide the requested storage."
  command     = "`chmod +x /agent/scripts/get_storage_class.sh && /agent/scripts/get_storage_class.sh`"
  params      = ["STORAGE_PROVIDER","STORAGE_CLASS_NAME"]
  file_deps   = ["get_storage_class"]
  enabled     = true
  depends_on  = [shoreline_file.get_storage_class]
}

resource "shoreline_action" "invoke_sprov_check" {
  name        = "invoke_sprov_check"
  description = "Check the storage provisioner and ensure that it is correctly configured and running."
  command     = "`chmod +x /agent/scripts/sprov_check.sh && /agent/scripts/sprov_check.sh`"
  params      = ["STORAGE_CLASS_NAME"]
  file_deps   = ["sprov_check"]
  enabled     = true
  depends_on  = [shoreline_file.sprov_check]
}

resource "shoreline_action" "invoke_delete_pvc" {
  name        = "invoke_delete_pvc"
  description = "Recreates Failed Persistent Volume Claims."
  command     = "`chmod +x /agent/scripts/delete_pvc.sh && /agent/scripts/delete_pvc.sh`"
  params      = ["PVC_NAME"]
  file_deps   = ["delete_pvc"]
  enabled     = true
  depends_on  = [shoreline_file.delete_pvc]
}

