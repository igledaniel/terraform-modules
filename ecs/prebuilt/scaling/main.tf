locals {
  high = "${var.high_metric_name}"
  low  = "${var.low_metric_name == "" ? local.high : var.low_metric_name}"
}

module "autoscaling_alarms" {
  source = "../../../autoscaling/alarms/custom"
  name   = "${module.service.service_name}"

  scale_up_arn   = "${module.service.scale_up_arn}"
  scale_down_arn = "${module.service.scale_down_arn}"

  high_metric_name = "${local.high}"
  low_metric_name  = "${local.low}"

  namespace = "${var.metric_namespace}"
}

module "service" {
  source = "../../modules/service/prebuilt/scaling"

  security_group_ids = ["${var.security_group_ids}"]
  subnets            = ["${var.subnets}"]
  vpc_id             = "${var.vpc_id}"
  namespace_id       = "${var.namespace_id}"

  task_definition_arn = "${module.task.task_definition_arn}"
  task_desired_count  = "${var.desired_task_count}"
  container_port      = "${var.container_port}"
  launch_type         = "${var.launch_type}"

  cluster_name = "${var.cluster_name}"
  service_name = "${var.service_name}"

  min_capacity = "${var.min_capacity}"
  max_capacity = "${var.max_capacity}"
}

module "task" {
  source = "../../modules/task/prebuilt/single_container"

  task_name = "${var.service_name}"

  container_port  = "${var.container_port}"
  container_image = "${var.container_image}"

  memory = "${var.memory}"
  cpu    = "${var.cpu}"

  env_vars        = "${var.env_vars}"
  env_vars_length = "${var.env_vars_length}"

  aws_region = "${var.aws_region}"

  command = "${var.command}"
}

locals {
  security_group_ids = "${concat(list(var.service_egress_security_group_id), var.security_group_ids)}"
}
