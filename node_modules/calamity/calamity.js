/*! Calamity 0.5.0-rc.5 - MIT license */
(function(){
// Import underscore if necessary.
if (typeof _ === "undefined" && typeof require === "function") {
	_ = require("underscore");
}

// Init Calamity object.
var C = {version: "0.5.0-rc.5"};

var root = this
// CommonJS
if (typeof exports !== "undefined") {
	if (typeof module !== "undefined" && module.exports) {
		exports = module.exports = C;
	}
	exports.C = C;
}
// AMD
else if (typeof define === "function" && define.amd) {
    define(['calamity'], C);
}
// Browser
else {
	root['Calamity'] = C;
}

var EmitterMixin, getEmitterBus, hasEmitterBus;

EmitterMixin = C.EmitterMixin = (function() {

  function EmitterMixin() {}

  EmitterMixin.prototype.on = function(address, handler, context) {
    context || (context = this);
    return getEmitterBus(this).subscribe(address, handler, context);
  };

  EmitterMixin.prototype.off = function(address, handler, context) {
    if (!hasEmitterBus(this)) {
      return;
    }
    context || (context = this);
    return getEmitterBus(this).unsubscribe(address, handler, context);
  };

  EmitterMixin.prototype.trigger = function(address, data, reply) {
    if (!hasEmitterBus(this)) {
      return;
    }
    return getEmitterBus(this).publish(address, data, reply);
  };

  return EmitterMixin;

})();

hasEmitterBus = function(obj) {
  if (!obj._calamity) {
    return false;
  }
  if (!obj._calamity.emitter) {
    return false;
  }
  if (!obj._calamity.emitter.bus) {
    return false;
  }
  return true;
};

getEmitterBus = function(obj) {
  var calamity, emitter;
  calamity = (obj._calamity || (obj._calamity = {}));
  emitter = (calamity.emitter || (calamity.emitter = {}));
  return emitter.bus || (emitter.bus = new EventBus());
};

C.emitter = function(obj) {
  return _.extend(obj, EmitterMixin.prototype);
};

var EventBridge;

EventBridge = C.EventBridge = (function() {

  C.emitter(EventBridge.prototype);

  function EventBridge() {}

  return EventBridge;

})();

var EventBus;

EventBus = C.EventBus = (function() {

  function EventBus() {
    this.id = util.genId();
    this._subscriptions = {};
    this._bridges = [];
  }

  EventBus.prototype.subscribe = function(address, handler, context) {
    var sub;
    if (!this._subscriptions[address]) {
      this._subscriptions[address] = [];
    }
    sub = new Subscription(address, handler, context, this);
    this._subscriptions[address].push(sub);
    this._bridgeProp("subscribe", {
      subscription: sub
    });
    return sub;
  };

  EventBus.prototype.unsubscribe = function(address, handler) {
    var i, s, sub, _i, _j, _len, _len1, _ref, _ref1;
    sub = address;
    if (sub instanceof Subscription) {
      address = sub.address;
      if (!this._subscriptions[address]) {
        return;
      }
      _ref = this._subscriptions[address];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        s = _ref[i];
        if (s === sub) {
          this._subscriptions[address].splice(i);
        }
      }
    } else {
      if (!this._subscriptions[address]) {
        return;
      }
      _ref1 = this._subscriptions[address];
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        s = _ref1[i];
        if (s.address === address && s.handler === handler) {
          sub = s;
          this._subscriptions[address].splice(i);
        }
      }
    }
    this._bridgeProp("unsubscribe", {
      subscription: sub
    });
  };

  EventBus.prototype.publish = function(address, data, reply) {
    var msg;
    msg = this._createMessage(address, data, reply);
    address = msg.address;
    if (msg.sawBus(this)) {
      return this;
    }
    msg.addBus(this);
    this._publishAddress(address, msg);
    this._publishAddress("*", msg);
    this._bridgeProp("publish", {
      message: msg
    });
    return this;
  };

  EventBus.prototype.send = function(address, data, reply) {
    var msg;
    msg = this._createMessage(address, data, reply);
    address = msg.address;
    if (msg.sawBus(this)) {
      return this;
    }
    msg.addBus(this);
    this._sendAddress(address, msg);
    this._bridgeProp("send", {
      message: msg
    });
    return this;
  };

  EventBus.prototype.bridge = function(bridge) {
    if (!(bridge instanceof EventBridge)) {
      throw new Error("Briges must extend Calamity.EventBridge");
    }
    if (!_.contains(this._bridges, bridge)) {
      this._bridges.push(bridge);
    }
    return this;
  };

  EventBus.prototype._createMessage = function(address, data, reply) {
    var msg;
    msg = address;
    if (!(msg instanceof EventMessage)) {
      msg = new EventMessage(address, data, reply);
    }
    return msg;
  };

  EventBus.prototype._publishAddress = function(address, msg) {
    var subscription, _i, _len, _ref;
    if (!this._subscriptions[address]) {
      return;
    }
    _ref = this._subscriptions[address];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      subscription = _ref[_i];
      subscription.trigger(msg);
    }
  };

  EventBus.prototype._sendAddress = function(address, msg) {
    var i, len, subs;
    if (!this._subscriptions[address]) {
      return;
    }
    subs = this._subscriptions[address];
    len = subs.length;
    i = Math.floor(Math.random() * len);
    subs[i].trigger(msg);
  };

  EventBus.prototype._bridgeProp = function(type, data) {
    var address, b, _i, _len, _ref;
    if (!(this._bridges.length > 0)) {
      return;
    }
    address = "bus." + type;
    data.bus = this;
    _ref = this._bridges;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      b = _ref[_i];
      b.trigger(address, data);
    }
  };

  return EventBus;

})();

var EventMessage;

EventMessage = C.EventMessage = (function() {

  function EventMessage(address, data, replyHandler) {
    this.address = address;
    this.data = data != null ? data : {};
    this.id = util.genId();
    this._busses = [];
    if (!(_.isUndefined(replyHandler) || _.isFunction(replyHandler))) {
      throw new Error("Reply must be a function");
    }
    this._replyHandler = replyHandler;
    this.status = "ok";
    this.error = null;
  }

  EventMessage.prototype.reply = function(data, replier) {
    var replyHandler;
    replyHandler = this._replyHandler;
    if (!_.isFunction(replyHandler)) {
      return;
    }
    if (!(data instanceof EventMessage)) {
      data = new EventMessage(null, data, replier);
    }
    replyHandler(data);
    return this;
  };

  EventMessage.prototype.replyError = function(error, data) {
    var msg, v, val, _i, _len, _ref;
    if (data == null) {
      data = {};
    }
    if (error instanceof Error) {
      _ref = "message,name,stack,fileName,lineNumber,description,number".split(",");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        val = error[v];
        if (val && typeof val.toString === "function") {
          val = val.toString();
        }
        data[v] = val;
      }
      if (typeof error.toString === "function") {
        data.string = error.toString();
        error = data.string;
        if (data.stack) {
          error += " :: " + data.stack;
        }
      }
    }
    msg = new EventMessage(null, data);
    msg.status = "error";
    msg.error = error;
    this.reply(msg);
    return this;
  };

  EventMessage.prototype["catch"] = function(other, handler) {
    if (handler == null) {
      if (!_.isFunction(other)) {
        throw new Error("Supplied handler is not a function, " + (typeof other) + " supplied");
      }
      handler = other;
      other = void 0;
    }
    if (!_.isFunction(this._replyHandler)) {
      if (other != null) {
        if (other instanceof EventMessage) {
          if (other.isError()) {
            throw other.error;
          }
        } else {
          if (!(other instanceof Error)) {
            other = new Error(other);
          }
          throw other;
        }
      }
      handler(other);
    } else {
      if (other != null) {
        if (other instanceof EventMessage) {
          if (other.isError()) {
            this.reply(other);
            return;
          }
        } else {
          if (!(other instanceof Error)) {
            other = new Error(other);
          }
          this.replyError(other);
          return;
        }
      }
      try {
        handler(other);
      } catch (err) {
        this.replyError(err);
      }
    }
  };

  EventMessage.prototype.isSuccess = function() {
    return this.status === "ok";
  };

  EventMessage.prototype.isError = function() {
    return this.status === "error";
  };

  EventMessage.prototype.getOptional = function(param, def) {
    var part, parts, val, _i, _len, _ref;
    parts = param.split(".");
    val = this.data[parts[0]];
    if (parts.length > 1) {
      _ref = parts.splice(1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        part = _ref[_i];
        if (_.isObject(val) && (val[part] != null)) {
          val = val[part];
        } else {
          val = void 0;
          break;
        }
      }
    }
    if (typeof val === "undefined") {
      return def;
    }
    return val;
  };

  EventMessage.prototype.getRequired = function(param) {
    var val;
    val = this.getOptional(param);
    if (typeof val === "undefined") {
      throw new Error("Variable \"" + param + "\" not found on message with address \"" + this.address + "\"");
    }
    return val;
  };

  EventMessage.prototype.addBus = function(bus) {
    if (this.sawBus(bus)) {
      return this;
    }
    this._busses.push(bus.id);
    return this;
  };

  EventMessage.prototype.sawBus = function(bus) {
    return _.contains(this._busses, bus.id);
  };

  EventMessage.prototype.toJSON = function() {
    var json;
    json = {
      calamity: C.version,
      address: this.address,
      data: this.data,
      status: this.status,
      error: this.error
    };
    if (this._replyHandler != null) {
      json.reply = _.bind(this.reply, this);
    }
    return json;
  };

  EventMessage.fromJSON = function(json) {
    var msg;
    if (!_.isObject(json)) {
      throw new Error("JSON must be an object");
    }
    if (json.calamity == null) {
      throw new Error("Serialized JSON is not for calamity: " + (JSON.stringify(json)));
    }
    msg = new EventMessage(json.address, json.data, json.reply);
    msg.status = json.status;
    msg.error = json.error;
    return msg;
  };

  return EventMessage;

})();

var MemoryEventBridge,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

MemoryEventBridge = C.MemoryEventBridge = (function(_super) {

  __extends(MemoryEventBridge, _super);

  function MemoryEventBridge() {
    return MemoryEventBridge.__super__.constructor.apply(this, arguments);
  }

  MemoryEventBridge.prototype.handler = function(msg) {
    var bus, _i, _len, _ref;
    _ref = this._busses;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      bus = _ref[_i];
      bus.publish(msg);
    }
  };

  return MemoryEventBridge;

})(EventBridge);

var PROXY_GLOBAL_BUS, ProxyMixin;

ProxyMixin = C.ProxyMixin = (function() {

  function ProxyMixin() {}

  ProxyMixin.prototype.subscribe = function(address, handler) {
    return this._calamity.proxy.bus.subscribe(address, handler, this);
  };

  ProxyMixin.prototype.publish = function(address, data, reply) {
    return this._calamity.proxy.bus.publish(address, data, reply);
  };

  ProxyMixin.prototype.send = function(address, data, reply) {
    return this._calamity.proxy.bus.send(address, data, reply);
  };

  return ProxyMixin;

})();

PROXY_GLOBAL_BUS = null;

C.global = function() {
  PROXY_GLOBAL_BUS || (PROXY_GLOBAL_BUS = new EventBus());
  return PROXY_GLOBAL_BUS;
};

C.proxy = function(obj, bus) {
  var c;
  if (!(bus instanceof EventBus)) {
    bus = C.global();
  }
  c = (obj._calamity || (obj._calamity = {}));
  c.proxy = {
    bus: bus
  };
  return _.extend(obj, ProxyMixin.prototype);
};

var Subscription;

Subscription = C.Subscription = (function() {

  function Subscription(address, handler, context, bus) {
    this.address = address;
    this.handler = handler;
    this.context = context;
    this.bus = bus;
    this.id = util.genId();
    this.active = true;
    return;
  }

  Subscription.prototype.unsubscribe = function() {
    if (!this.active) {
      return;
    }
    this.bus.unsubscribe(this);
    this.active = false;
    return this;
  };

  Subscription.prototype.trigger = function(msg) {
    var bound;
    if (!this.active) {
      return this;
    }
    bound = _.bind(this.handler, this.context);
    bound(msg);
    return this;
  };

  return Subscription;

})();

var HEX, floor, random, util;

random = Math.random;

floor = Math.floor;

HEX = "0123456789abcdef".split("");

util = C.util = {
  genId: function() {
    var i, id, _i;
    id = "";
    for (i = _i = 1; _i <= 32; i = ++_i) {
      id += HEX[floor(random() * HEX.length)];
    }
    return id;
  }
};
}).call(this);