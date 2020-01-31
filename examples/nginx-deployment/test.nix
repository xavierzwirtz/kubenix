{ config, lib, pkgs, kubenix, ... }:

with lib;

{
  imports = [ kubenix.modules.test ./module.nix ];

  test = {
    distro = "k3s";
    name = "nginx-deployment";
    description = "Test testing nginx deployment";
    testScript = ''
        $kube->waitUntilSucceeds("docker load --input='${config.docker.images.nginx.image}'");
        $kube->waitUntilSucceeds("kubectl apply -f ${config.kubernetes.result}");

        $kube->succeed("kubectl get deployment | grep -i nginx");
        $kube->waitUntilSucceeds("kubectl get deployment -o go-template nginx --template={{.status.readyReplicas}} | grep 10");
        #$kube->waitUntilSucceeds("${pkgs.curl}/bin/curl http://nginx.default.svc.cluster.local | grep -i hello");
    '';
  };
}
