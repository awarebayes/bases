from collections import defaultdict
import faker
import random
from dataclasses import dataclass, asdict, fields
from typing import Dict
import pandas as pd
from tqdm import tqdm

docker_images = (
    pd.read_csv("res/docker_images.csv", index_col=False, header=0)
    .transpose()
    .iloc[0]
    .tolist()
)
faker = faker.Faker()


class Fakable:

    id_cnt: Dict[str, int] = defaultdict(lambda: 0)

    def fake_(self, super_base):
        for field in fields(self):
            if field.name == "ID":
                self.id_cnt[super_base] = self.id_cnt[super_base] + 1
                setattr(self, field.name, self.id_cnt[super_base])
            elif field.type == bool:
                setattr(self, field.name, random.choice([True, False]))
            elif field.type == int:
                setattr(self, field.name, random.randint(0, 100))
            elif field.type == float:
                setattr(self, field.name, random.random() * 100)
            elif field.type == str:
                setattr(self, field.name, faker.word())

    @staticmethod
    def max_id_for(foreign_key_name):
        max_id = Fakable.id_cnt[foreign_key_name]
        assert max_id > 0, "Table was not generated yet!"
        return max_id - 1


@dataclass
class Image(Fakable):
    ID: int = 0
    Owner: str = ""
    Name: str = ""
    Downloads: int = 0
    NeedDevice: bool = False
    ImageSize: float = 0.0
    DockerVersion: str = ""
    Runtime: str = ""

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Owner = faker.company()
        self.Name = random.choice(docker_images)
        self.DockerVersion = (
            str(random.randint(0, 100))
            + "."
            + str(random.randint(0, 100))
            + "."
            + str(random.randint(0, 100))
        )
        self.Runtime = random.choice(
            [
                "nvidia-docker",
                "docker",
                "containerd",
                "podman",
                "cri-o",
                "docker-compose",
                "docker-x11",
            ]
        )

        return asdict(self)


@dataclass
class Task(Fakable):
    ID: int = 0
    Name: str = ""
    Project: str = ""
    NodeID: int = 1
    ImageID: int = 1
    NeedCUDA: bool = False
    Status: int = 0
    DispatcherID: int = 1
    TimeCreated: str = ""

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Name = faker.word()
        self.Project = faker.word()
        self.NodeID = random.randint(1, Fakable.max_id_for("Node"))
        self.ImageID = random.randint(1, Fakable.max_id_for("Image"))
        self.Status = random.randint(1, Fakable.max_id_for("TaskStatus"))
        self.DispatcherID = random.randint(1, Fakable.max_id_for("Dispatcher"))
        self.TimeCreated = str(faker.date_time_this_month())

        return asdict(self)


@dataclass
class Dispatcher(Fakable):
    ID: int = 0
    Name: str = ""
    Email: str = ""
    MatterMost: str = ""

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Name = faker.name()
        self.Email = faker.email()
        self.MatterMost = faker.name()

        return asdict(self)


@dataclass
class Node(Fakable):
    ID: int = 0
    IP: str = ""
    DeviceCount: int = 0
    RAM: float = 0

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.IP = faker.ipv4()
        self.DeviceCount = random.randint(0, 8)
        self.RAM = random.random() * 256

        return asdict(self)


@dataclass
class TaskStatus(Fakable):
    ID: int = 0
    Status: str = ""

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)
        return asdict(self)


@dataclass
class Volume(Fakable):
    ID: int = 0
    TaskID: int = 0
    host_path: str = ""
    container_path: str = "random/path"

    def random_path(self):
        path = ""
        for _ in range(random.randint(1, 8)):
            path += faker.word() + "/"
        return path

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)
        if random.random() > 0.7:
            path = self.random_path()
        else:
            path = (
                faker.url()
                + "file"
                + random.choice([".csv", ".pth", ".trt", ".hdf5", ".db"])
            )

        self.host_path = path
        self.container_path = self.random_path()
        self.TaskID = random.randint(1, Fakable.max_id_for("Task"))

        return asdict(self)


to_generate = [Image, Dispatcher, Node, TaskStatus, Task, Volume]

for gen in to_generate:
    data = []
    print()
    print("Generating", gen.__name__)
    for _ in tqdm(range(1000)):
        data.append(gen().fake())
    df = pd.DataFrame(data)
    df.to_csv(f"res/{gen.__name__}.csv", index=False)
