#!/usr/bin/env python3
import os
from os.path import dirname, join
from jinja2 import Environment, FileSystemLoader


def generate_ks_files(n):
    curdir = dirname(__file__)
    env = Environment(loader = FileSystemLoader(join(curdir, 'templates')))
    template = env.get_template('template-ks.cfg')

    for i in range(1, n + 1):
        cfg = template.render({
            'i': i,
            'n': n,
        })

        target_filename = join(curdir, 'ftp/node{}-ks.cfg'.format(i))
        with open(target_filename, "w") as f:
            f.write(cfg)


if __name__ == '__main__':
    n = int(os.environ.get('KEY_THAT_MIGHT_EXIST', '3'))
    generate_ks_files(n)
