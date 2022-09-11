from collections import defaultdict
from email.policy import default
import faker 
import random
from dataclasses import dataclass, asdict, fields
from typing import Dict
import pandas as pd

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


@dataclass
class Image(Fakable):
    ID: int = 0
    Owner: str = ''
    Name: str = ''
    Downloads: int = 0
    NeedDevice: bool = False
    Size: float = 0.0
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
    Status: str = ''
    DispatcherID: int   = 0

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Name = faker.Faker().job()
        self.Project = faker.Faker().name()
        self.NodeID = random.randint(0, 1000)
        self.ImageID = random.randint(0, 1000)
        self.Status = random.choice(["running", "pending", "failed", "done"])
        self.DispatcherID = random.randint(0, 1000)

        return asdict(self)


@dataclass
class Dispatcher(Fakable):
    ID: int = 0
    Name: str = ''
    Email: str  = ''
    MatterMost: str = ''
    RoleID: int = 0

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Name = faker.Faker().name()
        self.Email = faker.Faker().email()
        self.MatterMost = faker.Faker().name()
        self.RoleID = random.randint(0, 10)

        return asdict(self)

@dataclass
class Node(Fakable):
    ID: int = 0
    IP: str = ''
    RoleIDRequirement: int = 0

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.IP = faker.Faker().ipv4()
        self.RoleIDRequirement = random.randint(0, 10)

        return asdict(self)

@dataclass
class TeamRole(Fakable):
    ID: int = 0
    Title: str = ''

    def fake(self) -> dict:
        super().fake_(self.__class__.__name__)

        self.Title = faker.Faker().job()

        return asdict(self)



to_generate = [Image, Task, Dispatcher, Node, TeamRole]

for gen in to_generate:
    df = pd.DataFrame([gen().fake() for _ in range(100)])
    df.to_csv(f"res/{gen.__name__}.csv", index=False)