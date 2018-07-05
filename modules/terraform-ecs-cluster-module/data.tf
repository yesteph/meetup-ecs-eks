//////
//////      Management of ansible vars for docker users and groups
//////

// We format each entry as YAML
data "template_file" "docker_users_and_groups_string" {
  template = "$${content}"

  vars {
    content = "${format("- user: %s\n  group: %s\n  uid: %s\n",
        lookup(var.docker_users_and_groups[count.index], "user"),
        lookup(var.docker_users_and_groups[count.index], "group"),
        lookup(var.docker_users_and_groups[count.index], "uid")
        )}"
  }

  count = "${length(var.docker_users_and_groups)}"
}

// We declare the dict YAML entry
data "template_file" "docker_users_and_groups" {
  template = "${file("${path.module}/templates/docker-users-and-groups.tpl")}"

  vars {
    content = "${join("",data.template_file.docker_users_and_groups_string.*.rendered)}"
  }
}

//////
//////      Management of ansible vars for docker directories
//////

// We compute docker directory' path
data "template_file" "docker_directories_outputs" {
  template = "$${content}"

  vars {
    content = "${format("%s/docker-persistent-dir/%s/%s",
        lookup(var.docker_directories[count.index], "directory_base_location"),
        local.cluster_name,
        lookup(var.docker_directories[count.index], "directory_name")
        )}"
  }

  count = "${length(var.docker_directories)}"
}

// We format each entry as YAML
data "template_file" "docker_directories_string" {
  template = "$${content}"

  vars {
    content = "${format("- directory: %s\n  user: %s\n  group: %s\n",
        element(data.template_file.docker_directories_outputs.*.rendered, count.index),
        lookup(var.docker_directories[count.index], "user"),
        lookup(var.docker_directories[count.index], "group")
        )}"
  }

  count = "${length(var.docker_directories)}"
}

// We declare the dict YAML entry
data "template_file" "docker_directories" {
  template = "${file("${path.module}/templates/docker-directories.tpl")}"

  vars {
    content = "${join("",data.template_file.docker_directories_string.*.rendered)}"
  }
}
