'use strict'

const { EventEmitter } = require('events')
const WebSocket = require('ws')

const CFG = {
    aria2: {
        url: 'ws://127.0.0.1:6800/jsonrpc',
        secret: ''
    }
}

let isURL = /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/

function isObject(o) {
    return o !== null && typeof o === 'object' && Array.isArray(o) === false
}

class Aria2 {
    constructor() {
        if (!CFG.aria2.url) throw Error('invalid config')
        this.url = CFG.aria2.url
        this.secret = CFG.aria2.secret ? `token:${CFG.aria2.secret}` : ''
        // _gd(global data) format(object): key=gid, value=gid data
        //   - gid data(object with gid):
        //     - status(string): download status
        //     - stream(object): with tellStatus method
        //     - info(object): with getFiles method
        this._gd = {}
        this._emt = new EventEmitter()
        this._ws = new WebSocket(this.url)
        this._ws.on('message', res => {
            this.parseResponse(res)
        })
        this._ws.on('error', err => {
            throw Error(err)
        })
        this._lastsid = null
        this.on('downInit', gid => {
            this._gd[gid] = { status: 'init', gid }
            this.getFiles(gid)
            this.tellStatus(gid)
            this._lastsid = setInterval(() => {
                this.tellStatus(gid)
            }, 1000)
        })
        this.on('downStatus', res => {
            this._gd[res.gid].stream = res
            this._gd[res.gid].status = res.status
        })
        this.on('downInfo', res => {
            this._gd[res.gid].info = res
        })
        this.on('downComplete', gid => {
            if (this._lastsid) clearInterval(this._lastsid)
            this.getFiles(gid)
            this.tellStatus(gid)
            this._gd[gid].status = 'complete'
        })
        this.on('downError', gid => {
            this._gd[gid].status = 'error'
        })
        this.on('response', res => {
            //console.log(res)
        })
    }

    send(body) {
        if (this._ws.readyState === 1) {
            this._ws.send(body)
        } else {
            setTimeout(() => {
                this._ws.send(body)
            }, 1000)
        }
    }

    on(event, cb) {
        if (event && typeof cb === 'function') {
            /**
             * @event response: param is jsonrpc message
             * @event error: param is jsonrpc message
             * @event success: param is jsonrpc message(object)
             * @event downInit: param is gid
             * @event downError: param is gid
             * @event downStatus: param is result(object with gid)
             * @event downInfo: param is result(object with gid)
             * @event downComplete: param is gid
             */
            this._emt.on(event, cb)
        }
    }

    addUri(url) {
        if (isURL.test(url)) {
            let req = {
                params: [this.secret, [url]],
                jsonrpc: '2.0',
                id: 'Init',
                method: 'aria2.addUri'
            }
            this.send(JSON.stringify(req))
        } else {
            throw Error('invalid url')
        }
    }

    getFiles(gid) {
        if (gid) {
            let req = {
                params: [this.secret, gid],
                jsonrpc: '2.0',
                id: `Info.${gid}`,
                method: 'aria2.getFiles'
            }
            this.send(JSON.stringify(req))
        }
    }

    tellStatus(gid) {
        if (gid) {
            let req = {
                params: [
                    this.secret,
                    gid,
                    [
                        'gid',
                        'status',
                        'totalLength',
                        'completedLength',
                        'errorCode',
                        'errorMessage',
                        'dir'
                    ]
                ],
                jsonrpc: '2.0',
                id: 'Status',
                method: 'aria2.tellStatus'
            }
            this.send(JSON.stringify(req))
        }
    }

    parseResponse(res) {
        try {
            res = JSON.parse(res)
        } catch (error) {
            throw Error('invalid response')
        }
        this._emt.emit('response', res)
        if (!isObject(res) || res.hasOwnProperty('error')) {
            //error response
            this._emt.emit('error', res)
        } else {
            //success response
            this._emt.emit('success', res)
            if (res.hasOwnProperty('id')) {
                //a request-response mapping pair
                switch (res.id.split('.')[0]) {
                    case 'Init':
                        this._emt.emit('downInit', res.result)
                        break
                    case 'Status':
                        this._emt.emit('downStatus', res.result)
                        break
                    case 'Info':
                        let { completedLength, length, path } = res.result[0]
                        this._emt.emit('downInfo', {
                            gid: res.id.split('.')[1],
                            path,
                            completedLength,
                            totalLength: length
                        })
                        break
                }
            } else {
                //a notification from server, has method, param as data
                switch (res.method) {
                    case 'aria2.onDownloadError':
                        this._emt.emit('downError', res.params[0].gid)
                        break
                    case 'aria2.onDownloadComplete':
                        this._emt.emit('downComplete', res.params[0].gid)
                        break
                }
            }
        }
    }

    getData(gid) {
        return this._gd[gid] || {}
    }
}

module.exports = Aria2
