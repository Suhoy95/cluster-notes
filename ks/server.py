#!/usr/bin/env python3
from os.path import dirname, join
from aiohttp import web


if __name__ == '__main__':
    curdir = dirname(__file__)
    app = web.Application()

    app.router.add_static('/', curdir)

    web.run_app(app, host='10.10.10.1', port=8080)
