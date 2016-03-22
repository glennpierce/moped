from __future__ import unicode_literals

import os, json, time, logging

import tornado.web

from mopidy import config, ext

from AllPlayController import AllPlayController


logger = logging.getLogger(__name__)


__version__ = '<%= version %>'


allplayerController = AllPlayController()
last_icecast_url = None


class RequestHandlerGetAllPlayDevices(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        self.write({'allplay_devices': allplayerController.GetPlayers()})


class RequestHandlerCreateZone(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def post(self):
        global last_icecast_url
        data = json.loads(self.request.body)
        player = allplayerController.GetAllPlayer()
        player.PlayUrl(data['icecastUri'])
        last_icecast_url = data['icecastUri']
        time.sleep(2)
        allplayerController.CreateZone(data['selected_devices'])
        

class RequestHandlerReSetupZone(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        global last_icecast_url

        player = allplayerController.GetAllPlayer()
        if last_icecast_url != None:
            logger.info("using last icecast uriL %s", last_icecast_url)
            player.PlayUrl(last_icecast_url)
        player.ReSetupZone()
        

class RequestHandlerPlayLastUrl(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        global last_icecast_url
        player = allplayerController.GetAllPlayer()
        logger.info("harley last_icecast_url: %s", str(last_icecast_url))
        if last_icecast_url != None:
            player.PlayUrl(last_icecast_url)


class RequestHandlerPlayUrl(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def post(self):
        global last_icecast_url

        last_icecast_url = self.get_argument('icecastUri')

        logger.critical("bob %s", last_icecast_url)

        player = allplayerController.GetAllPlayer()
        player.PlayUrl(last_icecast_url)


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


class RequestHandlerResume(tornado.web.RequestHandler):
    def initialize(self, core):
        self.core = core

    def get(self):
        player = allplayerController.GetAllPlayer()
        player.Resume()


def allplay_factory(config, core):
    return [
        ('/get_devices', RequestHandlerGetAllPlayDevices, {'core': core}),
        ('/create_zone', RequestHandlerCreateZone, {'core': core}),
        ('/resetup_zone', RequestHandlerReSetupZone, {'core': core}),
        ('/play_lasturi', RequestHandlerPlayLastUrl, {'core': core}),
        ('/play_uri', RequestHandlerPlayUrl, {'core': core}),
        ('/play', RequestHandlerPlay, {'core': core}),
        ('/stop', RequestHandlerStop, {'core': core}),
        ('/pause', RequestHandlerPause, {'core': core}),
        ('/resume', RequestHandlerResume, {'core': core}),
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


