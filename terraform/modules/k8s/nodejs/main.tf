resource "null_resource" "c7a" {
  triggers {
    c7a = "${var.c7a-ips_id}"
  }
}

data "template_file" "c7a-0" {
  template = "${file("${path.root}/data/cassandra-0-ip.txt")}"
  depends_on = ["null_resource.c7a"]
}

data "template_file" "c7a-1" {
  template = "${file("${path.root}/data/cassandra-1-ip.txt")}"
  depends_on = ["null_resource.c7a"]
}

resource "null_resource" "nodejs-deployment" {
  provisioner "local-exec" {
    command = <<EOF
    echo '${data.template_file.deployment.rendered}' > /tmp/deployment.yaml &&
    kubectl delete --kubeconfig=$HOME/.kube/config --ignore-not-found=true -f /tmp/deployment.yaml &&
    kubectl create --kubeconfig=$HOME/.kube/config -f /tmp/deployment.yaml --save-config &&
    kubectl expose --kubeconfig=$HOME/.kube/config deployment nodejs --type="LoadBalancer"
  EOF
  }
  depends_on = ["data.template_file.c7a-0"]
}

data "template_file" "deployment" {
  template = "${file("${path.root}/data/njs_deployment.yml")}"
  vars {
    c7a-1-ip = "${data.template_file.c7a-0.rendered}"
    c7a-2-ip = "${data.template_file.c7a-1.rendered}"
    gmaps-key = "${var.gmaps_api_key}"
  }
}
