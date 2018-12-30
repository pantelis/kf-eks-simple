local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["tf-job-gpu"];

local k = import "k.libsonnet";

local name = params.name;
local namespace = env.namespace;
local image = "gcr.io/kubeflow/tf-benchmarks-gpu:v20171202-bdab599-dirty-284af3";
// local mount = container.volumeMountsType;
// local volume = depl.mixin.spec.template.spec.volumesType;


local tfjob = {
  apiVersion: "kubeflow.org/v1alpha2",
  kind: "TFJob",
  metadata: {
    name: name,
    namespace: namespace,
  },
  spec: {
    tfReplicaSpecs: {
      Worker: {
        replicas: 1,
        template: {
          spec: {
            containers: [
              {
                args: [
                  "python",
                  "tf_cnn_benchmarks.py",
                  "--batch_size=32",
                  "--model=resnet50",
                  "--variable_update=parameter_server",
                  "--flush_stdout=true",
                  "--num_gpus=1",
                  "--local_parameter_device=gpu",
                  "--device=gpu",
                  "--data_format=NHWC",
                  "--data_dir=/efs/jobs",
                  "--train_dir=/efs/jobs",
                  "--eval_dir=/efs/jobs",
                  "--data_name='coco'"
                ],
                image: image,
                name: "tensorflow",
                workingDir: "/opt/tf-benchmarks/scripts/tf_cnn_benchmarks",
              },
            ],
            restartPolicy: "OnFailure",
          },
        },
      },
      Ps: {
        template: {
          spec: {
            containers: [
              {
                args: [
                  "python",
                  "tf_cnn_benchmarks.py",
                  "--batch_size=32",
                  "--model=resnet50",
                  "--variable_update=parameter_server",
                  "--flush_stdout=true",
                  "--num_gpus=1",
                  "--local_parameter_device=gpu",
                  "--device=gpu",
                  "--data_format=NHWC",
                  "--data_dir=/efs/jobs",
                  "--train_dir=/efs/jobs",
                  "--eval_dir=/efs/jobs",
                  "--data_name='coco'"
                ],
                image: image,
                name: "tensorflow",
                workingDir: "/opt/tf-benchmarks/scripts/tf_cnn_benchmarks",
              },
            ],
            restartPolicy: "OnFailure",
          },
        },
        tfReplicaType: "PS",
      },
    },
  },
};

k.core.v1.list.new([
  tfjob,
])
