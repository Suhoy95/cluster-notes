#!/usr/bin/env python3
import random
import os
import json
from os.path import dirname, join
from jinja2 import Environment, FileSystemLoader



def randomMAC():
    return "52:54:00:%02x:%02x:%02x" % (
        random.randint(0, 255),
        random.randint(0, 255),
        random.randint(0, 255),
        )


curdir = dirname(__file__)
env = Environment(loader = FileSystemLoader(join(curdir, 'templates')))
template = env.get_template('node.xml')

with open('nodes.json') as f:
    nodes = json.load(f)

for node in nodes:
    node['mac2'] = randomMAC()
    node['pxeboot'] = os.environ.get('PXEBOOT', 'false') == 'true'
    xml = template.render(node)

    target_filename = join(curdir, 'nodes/{}.xml'.format(node['name']))
    with open(target_filename, "w") as f:
        f.write(xml)
