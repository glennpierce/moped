from __future__ import unicode_literals

import os

import tornado.web

from mopidy import config, ext

from AllPlayController import AllPlayController


__version__ = '<%= version %>'


allplayerController = AllPlayController()


class RequestHandlerGetAllPlayDevices(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        self.write({'allplay_devices': allplayerController.GetPlayers()})


class RequestHandlerCreateZone(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def post(self):
        print "here"
        print self.get_argument('selected_devices')
        selected_devices = self.get_argument('selected_devices')
        player = allplayerController.GetAllPlayer()
        player.CreateZone(selected_devices)

class RequestHandlerPlayUrl(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def post(self):
        icecastUri = self.get_argument('icecastUri')
        player = allplayerController.GetAllPlayer()
        player.PlayUrl(icecastUri)

class RequestHandlerPlay(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core
    def get(self):
        player = allplayerController.GetAllPlayer()
        player.Play()

class RequestHandlerStop(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        player = allplayerController.GetAllPlayer()
        player.Stop()

class RequestHandlerPause(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        player = allplayerController.GetAllPlayer()
        player.Pause()


def allplay_factory(config, core):
    return [
        ('/get_devices', RequestHandlerGetAllPlayDevices, {'core': core}),
        ('/create_zone', RequestHandlerCreateZone, {'core': core}),
        ('/play_uri', RequestHandlerPlayUrl, {'core': core}),
        ('/play', RequestHandlerPlay, {'core': core}),
        ('/stop', RequestHandlerStop, {'core': core}),
        ('/pause', RequestHandlerPause, {'core': core}),
    ]


class MopedExtension(ext.Extension):
    dist_name = 'Mopidy-Moped'
    ext_name = 'moped'
    version = __version__

    def get_default_config(self):
        conf_file = os.path.join(os.path.dirname(__file__), 'ext.conf')
        return config.read(conf_file)

    def setup(self, registry):
        registry.add('http:static', {
            'name': self.ext_name,
            'path': os.path.join(os.path.dirname(__file__), 'static'),
        })

        registry.add('http:app', {
            'name': self.ext_name,
            'factory': allplay_factory,
        })


