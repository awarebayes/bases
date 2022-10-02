COPY images(id, owner, image_name, downloads, need_device, image_size, docker_version, runtime)
FROM '/res/Image.csv'
DELIMITER ','
CSV HEADER;

COPY task_statuses(id, status)
FROM '/res/TaskStatus.csv'
DELIMITER ','
CSV HEADER;

COPY nodes(id, ip, device_count, ram)
FROM '/res/Node.csv'
DELIMITER ','
CSV HEADER;

COPY dispatchers(id, name,email, mattermost)
FROM '/res/Dispatcher.csv'
DELIMITER ','
CSV HEADER;

COPY tasks(id, name, project, node_id, image_id, need_cuda, status_id, dispatcher_id)
FROM '/res/Task.csv'
DELIMITER ','
CSV HEADER;

COPY volumes(id, task_id, host_path, container_path)
FROM '/res/Volume.csv'
DELIMITER ','
CSV HEADER;