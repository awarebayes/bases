from collections import defaultdict
from email.policy import default
import faker 
import random
from dataclasses import dataclass, asdict, fields
from typing import Dict
import pandas as pd
from tqdm import tqdm

docker_images = pd.read_csv('res/docker_images.csv', index_col=False, header=0).transpose().iloc[0].tolist()

class Fakable:

    id_cnt = defaultdict(int)

    def fake_(self, super_base) -> Dict:
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

    @staticmethod
    def max_id_for(foreign_key_name):
        max_id = Fakable.id_cnt[foreign_key_name]
        assert max_id > 0, "Table was not generated yet!"
        return max_id - 1


@dataclass
class Image(Fakable):
    ID: int = 0
    Owner: str = ''
    Name: str = ''
    Downloads: int = 0
    NeedDevice: bool = False
    ImageSize: float = 0.0
    DockerVersion: str = ''
    Runtime: str = ''

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Owner = faker.Faker().company()
        self.Name = random.choice(docker_images)
        self.DockerVersion = str(random.randint(0, 100)) + "." + str(random.randint(0, 100)) + "." + str(random.randint(0, 100))
        self.Runtime = random.choice(["nvidia-docker", "docker", "containerd", "podman", "cri-o", "docker-compose", "docker-x11"])

        return asdict(self)


@dataclass
class Task(Fakable):
    ID: int = 0
    Name: str = ''
    Project: str = ''
    NodeID: int     = 0
    ImageID: int = 0
    NeedCUDA: bool = False
    Status: int = 0
    DispatcherID: int   = 0

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Name = faker.Faker().word()
        self.Project = faker.Faker().word()
        self.NodeID = random.randint(0, Fakable.max_id_for("Node"))
        self.ImageID = random.randint(0, Fakable.max_id_for("Image"))
        self.Status = random.randint(0, Fakable.max_id_for("TaskStatus"))
        self.DispatcherID = random.randint(0, 1000)

        return asdict(self)


@dataclass
class Dispatcher(Fakable):
    ID: int = 0
    Name: str = ''
    Email: str  = ''
    MatterMost: str = ''

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Name = faker.Faker().name()
        self.Email = faker.Faker().email()
        self.MatterMost = faker.Faker().name()

        return asdict(self)

@dataclass
class Node(Fakable):
    ID: int = 0
    IP: str = ''
    DeviceCount: int = 0

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.IP = faker.Faker().ipv4()
        self.RoleIDRequirement = random.randint(0, 10)
        self.DeviceCount = random.randint(0, 8)

        return asdict(self)

@dataclass
class TaskStatus(Fakable):
    ID: int = 0
    Status: str = ''

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)
        return asdict(self)

statuses = []
available_statuses = ["Preparing", "Synching", "Running", "Completed", "Failed"]
for status in available_statuses:
    s = TaskStatus().fake()
    s['Status'] = status
    statuses.append(s)
df = pd.DataFrame(statuses)
df.to_csv(f"res/TaskStatus.csv", index=False)



to_generate = [Image, Dispatcher, Node, Task]

for gen in to_generate:
    data = []
    print()
    print("Generating", gen.__name__)
    for _ in tqdm(range(1000)):
        data.append(gen().fake())
    df = pd.DataFrame(data)
    df.to_csv(f"res/{gen.__name__}.csv", index=False)
