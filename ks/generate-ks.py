#!/usr/bin/env python3
from os.path import dirname, join
from jinja2 import Environment, FileSystemLoader


def generate_ks_files(n):
    curdir = dirname(__file__)
    env = Environment(loader = FileSystemLoader(curdir))
    template = env.get_template('template-ks.cfg')

    for i in range(n):
        cfg = template.render({
            "ip": "10.10.10.{}".format(i + 1),
            "hostname": "node{}".format(i),
        })
        target_filename = join(curdir, 'node{}-ks.cfg'.format(i))
        with open(target_filename, "w") as f:
            f.write(cfg)


if __name__ == '__main__':
    generate_ks_files(3)
