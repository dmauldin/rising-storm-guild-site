; (function($) {
    $.ui = {
        plugin: {
            add: function(module, option, set) {
                var proto = $.ui[module].prototype;
                for (var i in set) {
                    proto.plugins[i] = proto.plugins[i] || [];
                    proto.plugins[i].push([option, set[i]]);
                }
            },
            call: function(instance, name, args) {
                var set = instance.plugins[name];
                if (!set) {
                    return;
                }
                for (var i = 0; i < set.length; i++) {
                    if (instance.options[set[i][0]]) {
                        set[i][1].apply(instance.element, args);
                    }
                }
            }
        },
        cssCache: {},
        css: function(name) {
            if ($.ui.cssCache[name]) {
                return $.ui.cssCache[name];
            }
            var tmp = $('<div class="ui-gen">').addClass(name).css({
                position: 'absolute',
                top: '-5000px',
                left: '-5000px',
                display: 'block'
            }).appendTo('body');
            $.ui.cssCache[name] = !!((!(/auto|default/).test(tmp.css('cursor')) || (/^[1-9]/).test(tmp.css('height')) || (/^[1-9]/).test(tmp.css('width')) || !(/none/).test(tmp.css('backgroundImage')) || !(/transparent|rgba\(0, 0, 0, 0\)/).test(tmp.css('backgroundColor'))));
            try {
                $('body').get(0).removeChild(tmp.get(0));
            } catch(e) {}
            return $.ui.cssCache[name];
        },
        disableSelection: function(e) {
            e.unselectable = "on";
            e.onselectstart = function() {
                return false;
            };
            if (e.style) {
                e.style.MozUserSelect = "none";
            }
        },
        enableSelection: function(e) {
            e.unselectable = "off";
            e.onselectstart = function() {
                return true;
            };
            if (e.style) {
                e.style.MozUserSelect = "";
            }
        },
        hasScroll: function(e, a) {
            var scroll = /top/.test(a || "top") ? 'scrollTop': 'scrollLeft',
            has = false;
            if (e[scroll] > 0) return true;
            e[scroll] = 1;
            has = e[scroll] > 0 ? true: false;
            e[scroll] = 0;
            return has;
        }
    };
    var _remove = $.fn.remove;
    $.fn.remove = function() {
        $("*", this).add(this).trigger("remove");
        return _remove.apply(this, arguments);
    };
    function getter(namespace, plugin, method) {
        var methods = $[namespace][plugin].getter || [];
        methods = (typeof methods == "string" ? methods.split(/,?\s+/) : methods);
        return ($.inArray(method, methods) != -1);
    }
    $.widget = function(name, prototype) {
        var namespace = name.split(".")[0];
        name = name.split(".")[1];
        $.fn[name] = function(options) {
            var isMethodCall = (typeof options == 'string'),
            args = Array.prototype.slice.call(arguments, 1);
            if (isMethodCall && getter(namespace, name, options)) {
                var instance = $.data(this[0], name);
                return (instance ? instance[options].apply(instance, args) : undefined);
            }
            return this.each(function() {
                var instance = $.data(this, name);
                if (isMethodCall && instance && $.isFunction(instance[options])) {
                    instance[options].apply(instance, args);
                } else if (!isMethodCall) {
                    $.data(this, name, new $[namespace][name](this, options));
                }
            });
        };
        $[namespace][name] = function(element, options) {
            var self = this;
            this.widgetName = name;
            this.widgetBaseClass = namespace + '-' + name;
            this.options = $.extend({},
            $.widget.defaults, $[namespace][name].defaults, options);
            this.element = $(element).bind('setData.' + name,
            function(e, key, value) {
                return self.setData(key, value);
            }).bind('getData.' + name,
            function(e, key) {
                return self.getData(key);
            }).bind('remove',
            function() {
                return self.destroy();
            });
            this.init();
        };
        $[namespace][name].prototype = $.extend({},
        $.widget.prototype, prototype);
    };
    $.widget.prototype = {
        init: function() {},
        destroy: function() {
            this.element.removeData(this.widgetName);
        },
        getData: function(key) {
            return this.options[key];
        },
        setData: function(key, value) {
            this.options[key] = value;
            if (key == 'disabled') {
                this.element[value ? 'addClass': 'removeClass'](this.widgetBaseClass + '-disabled');
            }
        },
        enable: function() {
            this.setData('disabled', false);
        },
        disable: function() {
            this.setData('disabled', true);
        }
    };
    $.widget.defaults = {
        disabled: false
    };
    $.ui.mouse = {
        mouseInit: function() {
            var self = this;
            this.element.bind('mousedown.' + this.widgetName,
            function(e) {
                return self.mouseDown(e);
            });
            if ($.browser.msie) {
                this._mouseUnselectable = this.element.attr('unselectable');
                this.element.attr('unselectable', 'on');
            }
            this.started = false;
        },
        mouseDestroy: function() {
            this.element.unbind('.' + this.widgetName); ($.browser.msie && this.element.attr('unselectable', this._mouseUnselectable));
        },
        mouseDown: function(e) { (this._mouseStarted && this.mouseUp(e));
            this._mouseDownEvent = e;
            var self = this,
            btnIsLeft = (e.which == 1),
            elIsCancel = (typeof this.options.cancel == "string" ? $(e.target).is(this.options.cancel) : false);
            if (!btnIsLeft || elIsCancel || !this.mouseCapture(e)) {
                return true;
            }
            this._mouseDelayMet = !this.options.delay;
            if (!this._mouseDelayMet) {
                this._mouseDelayTimer = setTimeout(function() {
                    self._mouseDelayMet = true;
                },
                this.options.delay);
            }
            if (this.mouseDistanceMet(e) && this.mouseDelayMet(e)) {
                this._mouseStarted = (this.mouseStart(e) !== false);
                if (!this._mouseStarted) {
                    e.preventDefault();
                    return true;
                }
            }
            this._mouseMoveDelegate = function(e) {
                return self.mouseMove(e);
            };
            this._mouseUpDelegate = function(e) {
                return self.mouseUp(e);
            };
            $(document).bind('mousemove.' + this.widgetName, this._mouseMoveDelegate).bind('mouseup.' + this.widgetName, this._mouseUpDelegate);
            return false;
        },
        mouseMove: function(e) {
            if ($.browser.msie && !e.button) {
                return this.mouseUp(e);
            }
            if (this._mouseStarted) {
                this.mouseDrag(e);
                return false;
            }
            if (this.mouseDistanceMet(e) && this.mouseDelayMet(e)) {
                this._mouseStarted = (this.mouseStart(this._mouseDownEvent, e) !== false); (this._mouseStarted ? this.mouseDrag(e) : this.mouseUp(e));
            }
            return ! this._mouseStarted;
        },
        mouseUp: function(e) {
            $(document).unbind('mousemove.' + this.widgetName, this._mouseMoveDelegate).unbind('mouseup.' + this.widgetName, this._mouseUpDelegate);
            if (this._mouseStarted) {
                this._mouseStarted = false;
                this.mouseStop(e);
            }
            return false;
        },
        mouseDistanceMet: function(e) {
            return (Math.max(Math.abs(this._mouseDownEvent.pageX - e.pageX), Math.abs(this._mouseDownEvent.pageY - e.pageY)) >= this.options.distance);
        },
        mouseDelayMet: function(e) {
            return this._mouseDelayMet;
        },
        mouseStart: function(e) {},
        mouseDrag: function(e) {},
        mouseStop: function(e) {},
        mouseCapture: function(e) {
            return true;
        }
    };
    $.ui.mouse.defaults = {
        cancel: null,
        distance: 1,
        delay: 0
    };
})(jQuery); (function($) {
    $.widget("ui.draggable", $.extend($.ui.mouse, {
        init: function() {
            var o = this.options;
            if (o.helper == 'original' && !(/(relative|absolute|fixed)/).test(this.element.css('position')))
            this.element.css('position', 'relative');
            this.element.addClass('ui-draggable'); (o.disabled && this.element.addClass('ui-draggable-disabled'));
            this.mouseInit();
        },
        mouseStart: function(e) {
            var o = this.options;
            if (this.helper || o.disabled || $(e.target).is('.ui-resizable-handle')) return false;
            var handle = !this.options.handle || !$(this.options.handle, this.element).length ? true: false;
            $(this.options.handle, this.element).find("*").andSelf().each(function() {
                if (this == e.target) handle = true;
            });
            if (!handle) return false;
            if ($.ui.ddmanager) $.ui.ddmanager.current = this;
            this.helper = $.isFunction(o.helper) ? $(o.helper.apply(this.element[0], [e])) : (o.helper == 'clone' ? this.element.clone() : this.element);
            if (!this.helper.parents('body').length) this.helper.appendTo((o.appendTo == 'parent' ? this.element[0].parentNode: o.appendTo));
            if (this.helper[0] != this.element[0] && !(/(fixed|absolute)/).test(this.helper.css("position"))) this.helper.css("position", "absolute");
            this.margins = {
                left: (parseInt(this.element.css("marginLeft"), 10) || 0),
                top: (parseInt(this.element.css("marginTop"), 10) || 0)
            };
            this.cssPosition = this.helper.css("position");
            this.offset = this.element.offset();
            this.offset = {
                top: this.offset.top - this.margins.top,
                left: this.offset.left - this.margins.left
            };
            this.offset.click = {
                left: e.pageX - this.offset.left,
                top: e.pageY - this.offset.top
            };
            this.offsetParent = this.helper.offsetParent();
            var po = this.offsetParent.offset();
            if (this.offsetParent[0] == document.body && $.browser.mozilla) po = {
                top: 0,
                left: 0
            };
            this.offset.parent = {
                top: po.top + (parseInt(this.offsetParent.css("borderTopWidth"), 10) || 0),
                left: po.left + (parseInt(this.offsetParent.css("borderLeftWidth"), 10) || 0)
            };
            var p = this.element.position();
            this.offset.relative = this.cssPosition == "relative" ? {
                top: p.top - (parseInt(this.helper.css("top"), 10) || 0) + this.offsetParent[0].scrollTop,
                left: p.left - (parseInt(this.helper.css("left"), 10) || 0) + this.offsetParent[0].scrollLeft
            }: {
                top: 0,
                left: 0
            };
            this.originalPosition = this.generatePosition(e);
            this.helperProportions = {
                width: this.helper.outerWidth(),
                height: this.helper.outerHeight()
            };
            if (o.cursorAt) {
                if (o.cursorAt.left != undefined) this.offset.click.left = o.cursorAt.left + this.margins.left;
                if (o.cursorAt.right != undefined) this.offset.click.left = this.helperProportions.width - o.cursorAt.right + this.margins.left;
                if (o.cursorAt.top != undefined) this.offset.click.top = o.cursorAt.top + this.margins.top;
                if (o.cursorAt.bottom != undefined) this.offset.click.top = this.helperProportions.height - o.cursorAt.bottom + this.margins.top;
            }
            if (o.containment) {
                if (o.containment == 'parent') o.containment = this.helper[0].parentNode;
                if (o.containment == 'document' || o.containment == 'window') this.containment = [0 - this.offset.relative.left - this.offset.parent.left, 0 - this.offset.relative.top - this.offset.parent.top, $(o.containment == 'document' ? document: window).width() - this.offset.relative.left - this.offset.parent.left - this.helperProportions.width - this.margins.left - (parseInt(this.element.css("marginRight"), 10) || 0), ($(o.containment == 'document' ? document: window).height() || document.body.parentNode.scrollHeight) - this.offset.relative.top - this.offset.parent.top - this.helperProportions.height - this.margins.top - (parseInt(this.element.css("marginBottom"), 10) || 0)];
                if (! (/^(document|window|parent)$/).test(o.containment)) {
                    var ce = $(o.containment)[0];
                    var co = $(o.containment).offset();
                    this.containment = [co.left + (parseInt($(ce).css("borderLeftWidth"), 10) || 0) - this.offset.relative.left - this.offset.parent.left, co.top + (parseInt($(ce).css("borderTopWidth"), 10) || 0) - this.offset.relative.top - this.offset.parent.top, co.left + Math.max(ce.scrollWidth, ce.offsetWidth) - (parseInt($(ce).css("borderLeftWidth"), 10) || 0) - this.offset.relative.left - this.offset.parent.left - this.helperProportions.width - this.margins.left - (parseInt(this.element.css("marginRight"), 10) || 0), co.top + Math.max(ce.scrollHeight, ce.offsetHeight) - (parseInt($(ce).css("borderTopWidth"), 10) || 0) - this.offset.relative.top - this.offset.parent.top - this.helperProportions.height - this.margins.top - (parseInt(this.element.css("marginBottom"), 10) || 0)];
                }
            }
            this.propagate("start", e);
            this.helperProportions = {
                width: this.helper.outerWidth(),
                height: this.helper.outerHeight()
            };
            if ($.ui.ddmanager && !o.dropBehaviour) $.ui.ddmanager.prepareOffsets(this, e);
            this.helper.addClass("ui-draggable-dragging");
            this.mouseDrag(e);
            return true;
        },
        convertPositionTo: function(d, pos) {
            if (!pos) pos = this.position;
            var mod = d == "absolute" ? 1: -1;
            return {
                top: (pos.top
                + this.offset.relative.top * mod
                + this.offset.parent.top * mod
                - (this.cssPosition == "fixed" || (this.cssPosition == "absolute" && this.offsetParent[0] == document.body) ? 0: this.offsetParent[0].scrollTop) * mod
                + (this.cssPosition == "fixed" ? $(document).scrollTop() : 0) * mod
                + this.margins.top * mod),
                left: (pos.left
                + this.offset.relative.left * mod
                + this.offset.parent.left * mod
                - (this.cssPosition == "fixed" || (this.cssPosition == "absolute" && this.offsetParent[0] == document.body) ? 0: this.offsetParent[0].scrollLeft) * mod
                + (this.cssPosition == "fixed" ? $(document).scrollLeft() : 0) * mod
                + this.margins.left * mod)
            };
        },
        generatePosition: function(e) {
            var o = this.options;
            var position = {
                top: (e.pageY
                - this.offset.click.top
                - this.offset.relative.top
                - this.offset.parent.top
                + (this.cssPosition == "fixed" || (this.cssPosition == "absolute" && this.offsetParent[0] == document.body) ? 0: this.offsetParent[0].scrollTop)
                - (this.cssPosition == "fixed" ? $(document).scrollTop() : 0)),
                left: (e.pageX
                - this.offset.click.left
                - this.offset.relative.left
                - this.offset.parent.left
                + (this.cssPosition == "fixed" || (this.cssPosition == "absolute" && this.offsetParent[0] == document.body) ? 0: this.offsetParent[0].scrollLeft)
                - (this.cssPosition == "fixed" ? $(document).scrollLeft() : 0))
            };
            if (!this.originalPosition) return position;
            if (this.containment) {
                if (position.left < this.containment[0]) position.left = this.containment[0];
                if (position.top < this.containment[1]) position.top = this.containment[1];
                if (position.left > this.containment[2]) position.left = this.containment[2];
                if (position.top > this.containment[3]) position.top = this.containment[3];
            }
            if (o.grid) {
                var top = this.originalPosition.top + Math.round((position.top - this.originalPosition.top) / o.grid[1]) * o.grid[1];
                position.top = this.containment ? (!(top < this.containment[1] || top > this.containment[3]) ? top: (!(top < this.containment[1]) ? top - o.grid[1] : top + o.grid[1])) : top;
                var left = this.originalPosition.left + Math.round((position.left - this.originalPosition.left) / o.grid[0]) * o.grid[0];
                position.left = this.containment ? (!(left < this.containment[0] || left > this.containment[2]) ? left: (!(left < this.containment[0]) ? left - o.grid[0] : left + o.grid[0])) : left;
            }
            return position;
        },
        mouseDrag: function(e) {
            this.position = this.generatePosition(e);
            this.positionAbs = this.convertPositionTo("absolute");
            this.position = this.propagate("drag", e) || this.position;
            if (!this.options.axis || this.options.axis != "y") this.helper[0].style.left = this.position.left + 'px';
            if (!this.options.axis || this.options.axis != "x") this.helper[0].style.top = this.position.top + 'px';
            if ($.ui.ddmanager) $.ui.ddmanager.drag(this, e);
            return false;
        },
        mouseStop: function(e) {
            if ($.ui.ddmanager && !this.options.dropBehaviour)
            $.ui.ddmanager.drop(this, e);
            if (this.options.revert) {
                var self = this;
                $(this.helper).animate(this.originalPosition, parseInt(this.options.revert, 10) || 500,
                function() {
                    self.propagate("stop", e);
                    self.clear();
                });
            } else {
                this.propagate("stop", e);
                this.clear();
            }
            return false;
        },
        clear: function() {
            this.helper.removeClass("ui-draggable-dragging");
            if (this.options.helper != 'original' && !this.cancelHelperRemoval) this.helper.remove();
            this.helper = null;
            this.cancelHelperRemoval = false;
        },
        plugins: {},
        uiHash: function(e) {
            return {
                helper: this.helper,
                position: this.position,
                absolutePosition: this.positionAbs,
                options: this.options
            };
        },
        propagate: function(n, e) {
            $.ui.plugin.call(this, n, [e, this.uiHash()]);
            return this.element.triggerHandler(n == "drag" ? n: "drag" + n, [e, this.uiHash()], this.options[n]);
        },
        destroy: function() {
            if (!this.element.data('draggable')) return;
            this.element.removeData("draggable").unbind(".draggable").removeClass('ui-draggable');
            this.mouseDestroy();
        }
    }));
    $.extend($.ui.draggable, {
        defaults: {
            appendTo: "parent",
            axis: false,
            cancel: ":input",
            delay: 0,
            distance: 1,
            helper: "original"
        }
    });
    $.ui.plugin.add("draggable", "cursor", {
        start: function(e, ui) {
            var t = $('body');
            if (t.css("cursor")) ui.options._cursor = t.css("cursor");
            t.css("cursor", ui.options.cursor);
        },
        stop: function(e, ui) {
            if (ui.options._cursor) $('body').css("cursor", ui.options._cursor);
        }
    });
    $.ui.plugin.add("draggable", "zIndex", {
        start: function(e, ui) {
            var t = $(ui.helper);
            if (t.css("zIndex")) ui.options._zIndex = t.css("zIndex");
            t.css('zIndex', ui.options.zIndex);
        },
        stop: function(e, ui) {
            if (ui.options._zIndex) $(ui.helper).css('zIndex', ui.options._zIndex);
        }
    });
    $.ui.plugin.add("draggable", "opacity", {
        start: function(e, ui) {
            var t = $(ui.helper);
            if (t.css("opacity")) ui.options._opacity = t.css("opacity");
            t.css('opacity', ui.options.opacity);
        },
        stop: function(e, ui) {
            if (ui.options._opacity) $(ui.helper).css('opacity', ui.options._opacity);
        }
    });
    $.ui.plugin.add("draggable", "iframeFix", {
        start: function(e, ui) {
            $(ui.options.iframeFix === true ? "iframe": ui.options.iframeFix).each(function() {
                $('<div class="ui-draggable-iframeFix" style="background: #fff;"></div>').css({
                    width: this.offsetWidth + "px",
                    height: this.offsetHeight + "px",
                    position: "absolute",
                    opacity: "0.001",
                    zIndex: 1000
                }).css($(this).offset()).appendTo("body");
            });
        },
        stop: function(e, ui) {
            $("div.DragDropIframeFix").each(function() {
                this.parentNode.removeChild(this);
            });
        }
    });
    $.ui.plugin.add("draggable", "scroll", {
        start: function(e, ui) {
            var o = ui.options;
            var i = $(this).data("draggable");
            o.scrollSensitivity = o.scrollSensitivity || 20;
            o.scrollSpeed = o.scrollSpeed || 20;
            i.overflowY = function(el) {
                do {
                    if (/auto|scroll/.test(el.css('overflow')) || (/auto|scroll/).test(el.css('overflow-y'))) return el;
                    el = el.parent();
                }
                while (el[0].parentNode);
                return $(document);
            } (this);
            i.overflowX = function(el) {
                do {
                    if (/auto|scroll/.test(el.css('overflow')) || (/auto|scroll/).test(el.css('overflow-x'))) return el;
                    el = el.parent();
                }
                while (el[0].parentNode);
                return $(document);
            } (this);
            if (i.overflowY[0] != document && i.overflowY[0].tagName != 'HTML') i.overflowYOffset = i.overflowY.offset();
            if (i.overflowX[0] != document && i.overflowX[0].tagName != 'HTML') i.overflowXOffset = i.overflowX.offset();
        },
        drag: function(e, ui) {
            var o = ui.options;
            var i = $(this).data("draggable");
            if (i.overflowY[0] != document && i.overflowY[0].tagName != 'HTML') {
                if ((i.overflowYOffset.top + i.overflowY[0].offsetHeight) - e.pageY < o.scrollSensitivity)
                i.overflowY[0].scrollTop = i.overflowY[0].scrollTop + o.scrollSpeed;
                if (e.pageY - i.overflowYOffset.top < o.scrollSensitivity)
                i.overflowY[0].scrollTop = i.overflowY[0].scrollTop - o.scrollSpeed;
            } else {
                if (e.pageY - $(document).scrollTop() < o.scrollSensitivity)
                $(document).scrollTop($(document).scrollTop() - o.scrollSpeed);
                if ($(window).height() - (e.pageY - $(document).scrollTop()) < o.scrollSensitivity)
                $(document).scrollTop($(document).scrollTop() + o.scrollSpeed);
            }
            if (i.overflowX[0] != document && i.overflowX[0].tagName != 'HTML') {
                if ((i.overflowXOffset.left + i.overflowX[0].offsetWidth) - e.pageX < o.scrollSensitivity)
                i.overflowX[0].scrollLeft = i.overflowX[0].scrollLeft + o.scrollSpeed;
                if (e.pageX - i.overflowXOffset.left < o.scrollSensitivity)
                i.overflowX[0].scrollLeft = i.overflowX[0].scrollLeft - o.scrollSpeed;
            } else {
                if (e.pageX - $(document).scrollLeft() < o.scrollSensitivity)
                $(document).scrollLeft($(document).scrollLeft() - o.scrollSpeed);
                if ($(window).width() - (e.pageX - $(document).scrollLeft()) < o.scrollSensitivity)
                $(document).scrollLeft($(document).scrollLeft() + o.scrollSpeed);
            }
        }
    });
    $.ui.plugin.add("draggable", "snap", {
        start: function(e, ui) {
            var inst = $(this).data("draggable");
            inst.snapElements = [];
            $(ui.options.snap === true ? '.ui-draggable': ui.options.snap).each(function() {
                var $t = $(this);
                var $o = $t.offset();
                if (this != inst.element[0]) inst.snapElements.push({
                    item: this,
                    width: $t.outerWidth(),
                    height: $t.outerHeight(),
                    top: $o.top,
                    left: $o.left
                });
            });
        },
        drag: function(e, ui) {
            var inst = $(this).data("draggable");
            var d = ui.options.snapTolerance || 20;
            var x1 = ui.absolutePosition.left,
            x2 = x1 + inst.helperProportions.width,
            y1 = ui.absolutePosition.top,
            y2 = y1 + inst.helperProportions.height;
            for (var i = inst.snapElements.length - 1; i >= 0; i--) {
                var l = inst.snapElements[i].left,
                r = l + inst.snapElements[i].width,
                t = inst.snapElements[i].top,
                b = t + inst.snapElements[i].height;
                if (! ((l - d < x1 && x1 < r + d && t - d < y1 && y1 < b + d) || (l - d < x1 && x1 < r + d && t - d < y2 && y2 < b + d) || (l - d < x2 && x2 < r + d && t - d < y1 && y1 < b + d) || (l - d < x2 && x2 < r + d && t - d < y2 && y2 < b + d))) continue;
                if (ui.options.snapMode != 'inner') {
                    var ts = Math.abs(t - y2) <= 20;
                    var bs = Math.abs(b - y1) <= 20;
                    var ls = Math.abs(l - x2) <= 20;
                    var rs = Math.abs(r - x1) <= 20;
                    if (ts) ui.position.top = inst.convertPositionTo("relative", {
                        top: t - inst.helperProportions.height,
                        left: 0
                    }).top;
                    if (bs) ui.position.top = inst.convertPositionTo("relative", {
                        top: b,
                        left: 0
                    }).top;
                    if (ls) ui.position.left = inst.convertPositionTo("relative", {
                        top: 0,
                        left: l - inst.helperProportions.width
                    }).left;
                    if (rs) ui.position.left = inst.convertPositionTo("relative", {
                        top: 0,
                        left: r
                    }).left;
                }
                if (ui.options.snapMode != 'outer') {
                    var ts = Math.abs(t - y1) <= 20;
                    var bs = Math.abs(b - y2) <= 20;
                    var ls = Math.abs(l - x1) <= 20;
                    var rs = Math.abs(r - x2) <= 20;
                    if (ts) ui.position.top = inst.convertPositionTo("relative", {
                        top: t,
                        left: 0
                    }).top;
                    if (bs) ui.position.top = inst.convertPositionTo("relative", {
                        top: b - inst.helperProportions.height,
                        left: 0
                    }).top;
                    if (ls) ui.position.left = inst.convertPositionTo("relative", {
                        top: 0,
                        left: l
                    }).left;
                    if (rs) ui.position.left = inst.convertPositionTo("relative", {
                        top: 0,
                        left: r - inst.helperProportions.width
                    }).left;
                }
            };
        }
    });
    $.ui.plugin.add("draggable", "connectToSortable", {
        start: function(e, ui) {
            var inst = $(this).data("draggable");
            inst.sortables = [];
            $(ui.options.connectToSortable).each(function() {
                if ($.data(this, 'sortable')) {
                    var sortable = $.data(this, 'sortable');
                    inst.sortables.push({
                        instance: sortable,
                        shouldRevert: sortable.options.revert
                    });
                    sortable.refreshItems();
                    sortable.propagate("activate", e, inst);
                }
            });
        },
        stop: function(e, ui) {
            var inst = $(this).data("draggable");
            $.each(inst.sortables,
            function() {
                if (this.instance.isOver) {
                    this.instance.isOver = 0;
                    inst.cancelHelperRemoval = true;
                    this.instance.cancelHelperRemoval = false;
                    if (this.shouldRevert) this.instance.options.revert = true;
                    this.instance.mouseStop(e);
                    this.instance.element.triggerHandler("sortreceive", [e, $.extend(this.instance.ui(), {
                        sender: inst.element
                    })], this.instance.options["receive"]);
                    this.instance.options.helper = this.instance.options._helper;
                } else {
                    this.instance.propagate("deactivate", e, inst);
                }
            });
        },
        drag: function(e, ui) {
            var inst = $(this).data("draggable"),
            self = this;
            var checkPos = function(o) {
                var l = o.left,
                r = l + o.width,
                t = o.top,
                b = t + o.height;
                return (l < (this.positionAbs.left + this.offset.click.left) && (this.positionAbs.left + this.offset.click.left) < r && t < (this.positionAbs.top + this.offset.click.top) && (this.positionAbs.top + this.offset.click.top) < b);
            };
            $.each(inst.sortables,
            function(i) {
                if (checkPos.call(inst, this.instance.containerCache)) {
                    if (!this.instance.isOver) {
                        this.instance.isOver = 1;
                        this.instance.currentItem = $(self).clone().appendTo(this.instance.element).data("sortable-item", true);
                        this.instance.options._helper = this.instance.options.helper;
                        this.instance.options.helper = function() {
                            return ui.helper[0];
                        };
                        e.target = this.instance.currentItem[0];
                        this.instance.mouseCapture(e, true);
                        this.instance.mouseStart(e, true, true);
                        this.instance.offset.click.top = inst.offset.click.top;
                        this.instance.offset.click.left = inst.offset.click.left;
                        this.instance.offset.parent.left -= inst.offset.parent.left - this.instance.offset.parent.left;
                        this.instance.offset.parent.top -= inst.offset.parent.top - this.instance.offset.parent.top;
                        inst.propagate("toSortable", e);
                    }
                    if (this.instance.currentItem) this.instance.mouseDrag(e);
                } else {
                    if (this.instance.isOver) {
                        this.instance.isOver = 0;
                        this.instance.cancelHelperRemoval = true;
                        this.instance.options.revert = false;
                        this.instance.mouseStop(e, true);
                        this.instance.options.helper = this.instance.options._helper;
                        this.instance.currentItem.remove();
                        if (this.instance.placeholder) this.instance.placeholder.remove();
                        inst.propagate("fromSortable", e);
                    }
                };
            });
        }
    });
    $.ui.plugin.add("draggable", "stack", {
        start: function(e, ui) {
            var group = $.makeArray($(ui.options.stack.group)).sort(function(a, b) {
                return (parseInt($(a).css("zIndex"), 10) || ui.options.stack.min) - (parseInt($(b).css("zIndex"), 10) || ui.options.stack.min);
            });
            $(group).each(function(i) {
                this.style.zIndex = ui.options.stack.min + i;
            });
            this[0].style.zIndex = ui.options.stack.min + group.length;
        }
    });
})(jQuery); (function($) {
    $.widget("ui.droppable", {
        init: function() {
            this.element.addClass("ui-droppable");
            this.isover = 0;
            this.isout = 1;
            var o = this.options,
            accept = o.accept;
            o = $.extend(o, {
                accept: o.accept && o.accept.constructor == Function ? o.accept: function(d) {
                    return $(d).is(accept);
                }
            });
            this.proportions = {
                width: this.element.outerWidth(),
                height: this.element.outerHeight()
            };
            $.ui.ddmanager.droppables.push(this);
        },
        plugins: {},
        ui: function(c) {
            return {
                draggable: (c.currentItem || c.element),
                helper: c.helper,
                position: c.position,
                absolutePosition: c.positionAbs,
                options: this.options,
                element: this.element
            };
        },
        destroy: function() {
            var drop = $.ui.ddmanager.droppables;
            for (var i = 0; i < drop.length; i++)
            if (drop[i] == this)
            drop.splice(i, 1);
            this.element.removeClass("ui-droppable ui-droppable-disabled").removeData("droppable").unbind(".droppable");
        },
        over: function(e) {
            var draggable = $.ui.ddmanager.current;
            if (!draggable || (draggable.currentItem || draggable.element)[0] == this.element[0]) return;
            if (this.options.accept.call(this.element, (draggable.currentItem || draggable.element))) {
                $.ui.plugin.call(this, 'over', [e, this.ui(draggable)]);
                this.element.triggerHandler("dropover", [e, this.ui(draggable)], this.options.over);
            }
        },
        out: function(e) {
            var draggable = $.ui.ddmanager.current;
            if (!draggable || (draggable.currentItem || draggable.element)[0] == this.element[0]) return;
            if (this.options.accept.call(this.element, (draggable.currentItem || draggable.element))) {
                $.ui.plugin.call(this, 'out', [e, this.ui(draggable)]);
                this.element.triggerHandler("dropout", [e, this.ui(draggable)], this.options.out);
            }
        },
        drop: function(e, custom) {
            var draggable = custom || $.ui.ddmanager.current;
            if (!draggable || (draggable.currentItem || draggable.element)[0] == this.element[0]) return false;
            var childrenIntersection = false;
            this.element.find(".ui-droppable").not(".ui-draggable-dragging").each(function() {
                var inst = $.data(this, 'droppable');
                if (inst.options.greedy && $.ui.intersect(draggable, $.extend(inst, {
                    offset: inst.element.offset()
                }), inst.options.tolerance)) {
                    childrenIntersection = true;
                    return false;
                }
            });
            if (childrenIntersection) return false;
            if (this.options.accept.call(this.element, (draggable.currentItem || draggable.element))) {
                $.ui.plugin.call(this, 'drop', [e, this.ui(draggable)]);
                this.element.triggerHandler("drop", [e, this.ui(draggable)], this.options.drop);
                return true;
            }
            return false;
        },
        activate: function(e) {
            var draggable = $.ui.ddmanager.current;
            $.ui.plugin.call(this, 'activate', [e, this.ui(draggable)]);
            if (draggable) this.element.triggerHandler("dropactivate", [e, this.ui(draggable)], this.options.activate);
        },
        deactivate: function(e) {
            var draggable = $.ui.ddmanager.current;
            $.ui.plugin.call(this, 'deactivate', [e, this.ui(draggable)]);
            if (draggable) this.element.triggerHandler("dropdeactivate", [e, this.ui(draggable)], this.options.deactivate);
        }
    });
    $.extend($.ui.droppable, {
        defaults: {
            disabled: false,
            tolerance: 'intersect'
        }
    });
    $.ui.intersect = function(draggable, droppable, toleranceMode) {
        if (!droppable.offset) return false;
        var x1 = (draggable.positionAbs || draggable.position.absolute).left,
        x2 = x1 + draggable.helperProportions.width,
        y1 = (draggable.positionAbs || draggable.position.absolute).top,
        y2 = y1 + draggable.helperProportions.height;
        var l = droppable.offset.left,
        r = l + droppable.proportions.width,
        t = droppable.offset.top,
        b = t + droppable.proportions.height;
        switch (toleranceMode) {
        case 'fit':
            return (l < x1 && x2 < r && t < y1 && y2 < b);
            break;
        case 'intersect':
            return (l < x1 + (draggable.helperProportions.width / 2) && x2 - (draggable.helperProportions.width / 2) < r && t < y1 + (draggable.helperProportions.height / 2) && y2 - (draggable.helperProportions.height / 2) < b);
            break;
        case 'pointer':
            return (l < ((draggable.positionAbs || draggable.position.absolute).left + (draggable.clickOffset || draggable.offset.click).left) && ((draggable.positionAbs || draggable.position.absolute).left + (draggable.clickOffset || draggable.offset.click).left) < r && t < ((draggable.positionAbs || draggable.position.absolute).top + (draggable.clickOffset || draggable.offset.click).top) && ((draggable.positionAbs || draggable.position.absolute).top + (draggable.clickOffset || draggable.offset.click).top) < b);
            break;
        case 'touch':
            return ((y1 >= t && y1 <= b) || (y2 >= t && y2 <= b) || (y1 < t && y2 > b)) && ((x1 >= l && x1 <= r) || (x2 >= l && x2 <= r) || (x1 < l && x2 > r));
            break;
        default:
            return false;
            break;
        }
    };
    $.ui.ddmanager = {
        current: null,
        droppables: [],
        prepareOffsets: function(t, e) {
            var m = $.ui.ddmanager.droppables;
            var type = e ? e.type: null;
            for (var i = 0; i < m.length; i++) {
                if (m[i].options.disabled || (t && !m[i].options.accept.call(m[i].element, (t.currentItem || t.element)))) continue;
                m[i].visible = m[i].element.is(":visible");
                if (!m[i].visible) continue;
                m[i].offset = m[i].element.offset();
                m[i].proportions = {
                    width: m[i].element.outerWidth(),
                    height: m[i].element.outerHeight()
                };
                if (type == "dragstart" || type == "sortactivate") m[i].activate.call(m[i], e);
            }
        },
        drop: function(draggable, e) {
            var dropped = false;
            $.each($.ui.ddmanager.droppables,
            function() {
                if (!this.options) return;
                if (!this.options.disabled && this.visible && $.ui.intersect(draggable, this, this.options.tolerance))
                dropped = this.drop.call(this, e);
                if (!this.options.disabled && this.visible && this.options.accept.call(this.element, (draggable.currentItem || draggable.element))) {
                    this.isout = 1;
                    this.isover = 0;
                    this.deactivate.call(this, e);
                }
            });
            return dropped;
        },
        drag: function(draggable, e) {
            if (draggable.options.refreshPositions) $.ui.ddmanager.prepareOffsets(draggable, e);
            $.each($.ui.ddmanager.droppables,
            function() {
                if (this.options.disabled || this.greedyChild || !this.visible) return;
                var intersects = $.ui.intersect(draggable, this, this.options.tolerance);
                var c = !intersects && this.isover == 1 ? 'isout': (intersects && this.isover == 0 ? 'isover': null);
                if (!c) return;
                var parentInstance;
                if (this.options.greedy) {
                    var parent = this.element.parents('.ui-droppable:eq(0)');
                    if (parent.length) {
                        parentInstance = $.data(parent[0], 'droppable');
                        parentInstance.greedyChild = (c == 'isover' ? 1: 0);
                    }
                }
                if (parentInstance && c == 'isover') {
                    parentInstance['isover'] = 0;
                    parentInstance['isout'] = 1;
                    parentInstance.out.call(parentInstance, e);
                }
                this[c] = 1;
                this[c == 'isout' ? 'isover': 'isout'] = 0;
                this[c == "isover" ? "over": "out"].call(this, e);
                if (parentInstance && c == 'isout') {
                    parentInstance['isout'] = 0;
                    parentInstance['isover'] = 1;
                    parentInstance.over.call(parentInstance, e);
                }
            });
        }
    };
    $.ui.plugin.add("droppable", "activeClass", {
        activate: function(e, ui) {
            $(this).addClass(ui.options.activeClass);
        },
        deactivate: function(e, ui) {
            $(this).removeClass(ui.options.activeClass);
        },
        drop: function(e, ui) {
            $(this).removeClass(ui.options.activeClass);
        }
    });
    $.ui.plugin.add("droppable", "hoverClass", {
        over: function(e, ui) {
            $(this).addClass(ui.options.hoverClass);
        },
        out: function(e, ui) {
            $(this).removeClass(ui.options.hoverClass);
        },
        drop: function(e, ui) {
            $(this).removeClass(ui.options.hoverClass);
        }
    });
})(jQuery); (function($) {
    function contains(a, b) {
        var safari2 = $.browser.safari && $.browser.version < 522;
        if (a.contains && !safari2) {
            return a.contains(b);
        }
        if (a.compareDocumentPosition)
        return !! (a.compareDocumentPosition(b) & 16);
        while (b = b.parentNode)
        if (b == a) return true;
        return false;
    };
    $.widget("ui.sortable", $.extend($.ui.mouse, {
        init: function() {
            var o = this.options;
            this.containerCache = {};
            this.element.addClass("ui-sortable");
            this.refresh();
            this.floating = this.items.length ? (/left|right/).test(this.items[0].item.css('float')) : false;
            if (! (/(relative|absolute|fixed)/).test(this.element.css('position'))) this.element.css('position', 'relative');
            this.offset = this.element.offset();
            this.mouseInit();
        },
        plugins: {},
        ui: function(inst) {
            return {
                helper: (inst || this)["helper"],
                placeholder: (inst || this)["placeholder"] || $([]),
                position: (inst || this)["position"],
                absolutePosition: (inst || this)["positionAbs"],
                options: this.options,
                element: this.element,
                item: (inst || this)["currentItem"],
                sender: inst ? inst.element: null
            };
        },
        propagate: function(n, e, inst, noPropagation) {
            $.ui.plugin.call(this, n, [e, this.ui(inst)]);
            if (!noPropagation) this.element.triggerHandler(n == "sort" ? n: "sort" + n, [e, this.ui(inst)], this.options[n]);
        },
        serialize: function(o) {
            var items = ($.isFunction(this.options.items) ? this.options.items.call(this.element) : $(this.options.items, this.element)).not('.ui-sortable-helper');
            var str = [];
            o = o || {};
            items.each(function() {
                var res = ($(this).attr(o.attribute || 'id') || '').match(o.expression || (/(.+)[-=_](.+)/));
                if (res) str.push((o.key || res[1]) + '[]=' + (o.key && o.expression ? res[1] : res[2]));
            });
            return str.join('&');
        },
        toArray: function(attr) {
            var items = ($.isFunction(this.options.items) ? this.options.items.call(this.element) : $(this.options.items, this.element)).not('.ui-sortable-helper');
            var ret = [];
            items.each(function() {
                ret.push($(this).attr(attr || 'id'));
            });
            return ret;
        },
        intersectsWith: function(item) {
            var x1 = this.positionAbs.left,
            x2 = x1 + this.helperProportions.width,
            y1 = this.positionAbs.top,
            y2 = y1 + this.helperProportions.height;
            var l = item.left,
            r = l + item.width,
            t = item.top,
            b = t + item.height;
            if (this.options.tolerance == "pointer" || (this.options.tolerance == "guess" && this.helperProportions[this.floating ? 'width': 'height'] > item[this.floating ? 'width': 'height'])) {
                return (y1 + this.offset.click.top > t && y1 + this.offset.click.top < b && x1 + this.offset.click.left > l && x1 + this.offset.click.left < r);
            } else {
                return (l < x1 + (this.helperProportions.width / 2) && x2 - (this.helperProportions.width / 2) < r && t < y1 + (this.helperProportions.height / 2) && y2 - (this.helperProportions.height / 2) < b);
            }
        },
        intersectsWithEdge: function(item) {
            var x1 = this.positionAbs.left,
            x2 = x1 + this.helperProportions.width,
            y1 = this.positionAbs.top,
            y2 = y1 + this.helperProportions.height;
            var l = item.left,
            r = l + item.width,
            t = item.top,
            b = t + item.height;
            if (this.options.tolerance == "pointer" || (this.options.tolerance == "guess" && this.helperProportions[this.floating ? 'width': 'height'] > item[this.floating ? 'width': 'height'])) {
                if (! (y1 + this.offset.click.top > t && y1 + this.offset.click.top < b && x1 + this.offset.click.left > l && x1 + this.offset.click.left < r)) return false;
                if (this.floating) {
                    if (x1 + this.offset.click.left > l && x1 + this.offset.click.left < l + item.width / 2) return 2;
                    if (x1 + this.offset.click.left > l + item.width / 2 && x1 + this.offset.click.left < r) return 1;
                } else {
                    if (y1 + this.offset.click.top > t && y1 + this.offset.click.top < t + item.height / 2) return 2;
                    if (y1 + this.offset.click.top > t + item.height / 2 && y1 + this.offset.click.top < b) return 1;
                }
            } else {
                if (! (l < x1 + (this.helperProportions.width / 2) && x2 - (this.helperProportions.width / 2) < r && t < y1 + (this.helperProportions.height / 2) && y2 - (this.helperProportions.height / 2) < b)) return false;
                if (this.floating) {
                    if (x2 > l && x1 < l) return 2;
                    if (x1 < r && x2 > r) return 1;
                } else {
                    if (y2 > t && y1 < t) return 1;
                    if (y1 < b && y2 > b) return 2;
                }
            }
            return false;
        },
        refresh: function() {
            this.refreshItems();
            this.refreshPositions();
        },
        refreshItems: function() {
            this.items = [];
            this.containers = [this];
            var items = this.items;
            var self = this;
            var queries = [[$.isFunction(this.options.items) ? this.options.items.call(this.element, null, {
                options: this.options,
                item: this.currentItem
            }) : $(this.options.items, this.element), this]];
            if (this.options.connectWith) {
                for (var i = this.options.connectWith.length - 1; i >= 0; i--) {
                    var cur = $(this.options.connectWith[i]);
                    for (var j = cur.length - 1; j >= 0; j--) {
                        var inst = $.data(cur[j], 'sortable');
                        if (inst && !inst.options.disabled) {
                            queries.push([$.isFunction(inst.options.items) ? inst.options.items.call(inst.element) : $(inst.options.items, inst.element), inst]);
                            this.containers.push(inst);
                        }
                    };
                };
            }
            for (var i = queries.length - 1; i >= 0; i--) {
                queries[i][0].each(function() {
                    $.data(this, 'sortable-item', queries[i][1]);
                    items.push({
                        item: $(this),
                        instance: queries[i][1],
                        width: 0,
                        height: 0,
                        left: 0,
                        top: 0
                    });
                });
            };
        },
        refreshPositions: function(fast) {
            if (this.offsetParent) {
                var po = this.offsetParent.offset();
                this.offset.parent = {
                    top: po.top + this.offsetParentBorders.top,
                    left: po.left + this.offsetParentBorders.left
                };
            }
            for (var i = this.items.length - 1; i >= 0; i--) {
                if (this.items[i].instance != this.currentContainer && this.currentContainer && this.items[i].item[0] != this.currentItem[0])
                continue;
                var t = this.options.toleranceElement ? $(this.options.toleranceElement, this.items[i].item) : this.items[i].item;
                if (!fast) {
                    this.items[i].width = t.outerWidth();
                    this.items[i].height = t.outerHeight();
                }
                var p = t.offset();
                this.items[i].left = p.left;
                this.items[i].top = p.top;
            };
            for (var i = this.containers.length - 1; i >= 0; i--) {
                var p = this.containers[i].element.offset();
                this.containers[i].containerCache.left = p.left;
                this.containers[i].containerCache.top = p.top;
                this.containers[i].containerCache.width = this.containers[i].element.outerWidth();
                this.containers[i].containerCache.height = this.containers[i].element.outerHeight();
            };
        },
        destroy: function() {
            this.element.removeClass("ui-sortable ui-sortable-disabled").removeData("sortable").unbind(".sortable");
            this.mouseDestroy();
            for (var i = this.items.length - 1; i >= 0; i--)
            this.items[i].item.removeData("sortable-item");
        },
        createPlaceholder: function(that) {
            var self = that || this,
            o = self.options;
            if (o.placeholder.constructor == String) {
                var className = o.placeholder;
                o.placeholder = {
                    element: function() {
                        return $('<div></div>').addClass(className)[0];
                    },
                    update: function(i, p) {
                        p.css(i.offset()).css({
                            width: i.outerWidth(),
                            height: i.outerHeight()
                        });
                    }
                };
            }
            self.placeholder = $(o.placeholder.element.call(self.element, self.currentItem)).appendTo('body').css({
                position: 'absolute'
            });
            o.placeholder.update.call(self.element, self.currentItem, self.placeholder);
        },
        contactContainers: function(e) {
            for (var i = this.containers.length - 1; i >= 0; i--) {
                if (this.intersectsWith(this.containers[i].containerCache)) {
                    if (!this.containers[i].containerCache.over) {
                        if (this.currentContainer != this.containers[i]) {
                            var dist = 10000;
                            var itemWithLeastDistance = null;
                            var base = this.positionAbs[this.containers[i].floating ? 'left': 'top'];
                            for (var j = this.items.length - 1; j >= 0; j--) {
                                if (!contains(this.containers[i].element[0], this.items[j].item[0])) continue;
                                var cur = this.items[j][this.containers[i].floating ? 'left': 'top'];
                                if (Math.abs(cur - base) < dist) {
                                    dist = Math.abs(cur - base);
                                    itemWithLeastDistance = this.items[j];
                                }
                            }
                            if (!itemWithLeastDistance && !this.options.dropOnEmpty)
                            continue;
                            if (this.placeholder) this.placeholder.remove();
                            if (this.containers[i].options.placeholder) {
                                this.containers[i].createPlaceholder(this);
                            } else {
                                this.placeholder = null;;
                            }
                            this.currentContainer = this.containers[i];
                            itemWithLeastDistance ? this.rearrange(e, itemWithLeastDistance, null, true) : this.rearrange(e, null, this.containers[i].element, true);
                            this.propagate("change", e);
                            this.containers[i].propagate("change", e, this);
                        }
                        this.containers[i].propagate("over", e, this);
                        this.containers[i].containerCache.over = 1;
                    }
                } else {
                    if (this.containers[i].containerCache.over) {
                        this.containers[i].propagate("out", e, this);
                        this.containers[i].containerCache.over = 0;
                    }
                }
            };
        },
        mouseCapture: function(e, overrideHandle) {
            if (this.options.disabled || this.options.type == 'static') return false;
            this.refreshItems();
            var currentItem = null,
            self = this,
            nodes = $(e.target).parents().each(function() {
                if ($.data(this, 'sortable-item') == self) {
                    currentItem = $(this);
                    return false;
                }
            });
            if ($.data(e.target, 'sortable-item') == self) currentItem = $(e.target);
            if (!currentItem) return false;
            if (this.options.handle && !overrideHandle) {
                var validHandle = false;
                $(this.options.handle, currentItem).find("*").andSelf().each(function() {
                    if (this == e.target) validHandle = true;
                });
                if (!validHandle) return false;
            }
            this.currentItem = currentItem;
            return true;
        },
        mouseStart: function(e, overrideHandle, noActivation) {
            var o = this.options;
            this.currentContainer = this;
            this.refreshPositions();
            this.helper = typeof o.helper == 'function' ? $(o.helper.apply(this.element[0], [e, this.currentItem])) : this.currentItem.clone();
            if (!this.helper.parents('body').length) this.helper.appendTo((o.appendTo != 'parent' ? o.appendTo: this.currentItem[0].parentNode));
            this.helper.css({
                position: 'absolute',
                clear: 'both'
            }).addClass('ui-sortable-helper');
            this.margins = {
                left: (parseInt(this.currentItem.css("marginLeft"), 10) || 0),
                top: (parseInt(this.currentItem.css("marginTop"), 10) || 0)
            };
            this.offset = this.currentItem.offset();
            this.offset = {
                top: this.offset.top - this.margins.top,
                left: this.offset.left - this.margins.left
            };
            this.offset.click = {
                left: e.pageX - this.offset.left,
                top: e.pageY - this.offset.top
            };
            this.offsetParent = this.helper.offsetParent();
            var po = this.offsetParent.offset();
            this.offsetParentBorders = {
                top: (parseInt(this.offsetParent.css("borderTopWidth"), 10) || 0),
                left: (parseInt(this.offsetParent.css("borderLeftWidth"), 10) || 0)
            };
            this.offset.parent = {
                top: po.top + this.offsetParentBorders.top,
                left: po.left + this.offsetParentBorders.left
            };
            this.originalPosition = this.generatePosition(e);
            this.domPosition = {
                prev: this.currentItem.prev()[0],
                parent: this.currentItem.parent()[0]
            };
            this.helperProportions = {
                width: this.helper.outerWidth(),
                height: this.helper.outerHeight()
            };
            if (o.placeholder) this.createPlaceholder();
            this.propagate("start", e);
            this.helperProportions = {
                width: this.helper.outerWidth(),
                height: this.helper.outerHeight()
            };
            if (o.cursorAt) {
                if (o.cursorAt.left != undefined) this.offset.click.left = o.cursorAt.left;
                if (o.cursorAt.right != undefined) this.offset.click.left = this.helperProportions.width - o.cursorAt.right;
                if (o.cursorAt.top != undefined) this.offset.click.top = o.cursorAt.top;
                if (o.cursorAt.bottom != undefined) this.offset.click.top = this.helperProportions.height - o.cursorAt.bottom;
            }
            if (o.containment) {
                if (o.containment == 'parent') o.containment = this.helper[0].parentNode;
                if (o.containment == 'document' || o.containment == 'window') this.containment = [0 - this.offset.parent.left, 0 - this.offset.parent.top, $(o.containment == 'document' ? document: window).width() - this.offset.parent.left - this.helperProportions.width - this.margins.left - (parseInt(this.element.css("marginRight"), 10) || 0), ($(o.containment == 'document' ? document: window).height() || document.body.parentNode.scrollHeight) - this.offset.parent.top - this.helperProportions.height - this.margins.top - (parseInt(this.element.css("marginBottom"), 10) || 0)];
                if (! (/^(document|window|parent)$/).test(o.containment)) {
                    var ce = $(o.containment)[0];
                    var co = $(o.containment).offset();
                    this.containment = [co.left + (parseInt($(ce).css("borderLeftWidth"), 10) || 0) - this.offset.parent.left, co.top + (parseInt($(ce).css("borderTopWidth"), 10) || 0) - this.offset.parent.top, co.left + Math.max(ce.scrollWidth, ce.offsetWidth) - (parseInt($(ce).css("borderLeftWidth"), 10) || 0) - this.offset.parent.left - this.helperProportions.width - this.margins.left - (parseInt(this.currentItem.css("marginRight"), 10) || 0), co.top + Math.max(ce.scrollHeight, ce.offsetHeight) - (parseInt($(ce).css("borderTopWidth"), 10) || 0) - this.offset.parent.top - this.helperProportions.height - this.margins.top - (parseInt(this.currentItem.css("marginBottom"), 10) || 0)];
                }
            }
            if (this.options.placeholder != 'clone')
            this.currentItem.css('visibility', 'hidden');
            if (!noActivation) {
                for (var i = this.containers.length - 1; i >= 0; i--) {
                    this.containers[i].propagate("activate", e, this);
                }
            }
            if ($.ui.ddmanager) $.ui.ddmanager.current = this;
            if ($.ui.ddmanager && !o.dropBehaviour) $.ui.ddmanager.prepareOffsets(this, e);
            this.dragging = true;
            this.mouseDrag(e);
            return true;
        },
        convertPositionTo: function(d, pos) {
            if (!pos) pos = this.position;
            var mod = d == "absolute" ? 1: -1;
            return {
                top: (pos.top
                + this.offset.parent.top * mod
                - (this.offsetParent[0] == document.body ? 0: this.offsetParent[0].scrollTop) * mod
                + this.margins.top * mod),
                left: (pos.left
                + this.offset.parent.left * mod
                - (this.offsetParent[0] == document.body ? 0: this.offsetParent[0].scrollLeft) * mod
                + this.margins.left * mod)
            };
        },
        generatePosition: function(e) {
            var o = this.options;
            var position = {
                top: (e.pageY
                - this.offset.click.top
                - this.offset.parent.top
                + (this.offsetParent[0] == document.body ? 0: this.offsetParent[0].scrollTop)),
                left: (e.pageX
                - this.offset.click.left
                - this.offset.parent.left
                + (this.offsetParent[0] == document.body ? 0: this.offsetParent[0].scrollLeft))
            };
            if (!this.originalPosition) return position;
            if (this.containment) {
                if (position.left < this.containment[0]) position.left = this.containment[0];
                if (position.top < this.containment[1]) position.top = this.containment[1];
                if (position.left > this.containment[2]) position.left = this.containment[2];
                if (position.top > this.containment[3]) position.top = this.containment[3];
            }
            if (o.grid) {
                var top = this.originalPosition.top + Math.round((position.top - this.originalPosition.top) / o.grid[1]) * o.grid[1];
                position.top = this.containment ? (!(top < this.containment[1] || top > this.containment[3]) ? top: (!(top < this.containment[1]) ? top - o.grid[1] : top + o.grid[1])) : top;
                var left = this.originalPosition.left + Math.round((position.left - this.originalPosition.left) / o.grid[0]) * o.grid[0];
                position.left = this.containment ? (!(left < this.containment[0] || left > this.containment[2]) ? left: (!(left < this.containment[0]) ? left - o.grid[0] : left + o.grid[0])) : left;
            }
            return position;
        },
        mouseDrag: function(e) {
            this.position = this.generatePosition(e);
            this.positionAbs = this.convertPositionTo("absolute");
            for (var i = this.items.length - 1; i >= 0; i--) {
                var intersection = this.intersectsWithEdge(this.items[i]);
                if (!intersection) continue;
                if (this.items[i].item[0] != this.currentItem[0] && this.currentItem[intersection == 1 ? "next": "prev"]()[0] != this.items[i].item[0] && !contains(this.currentItem[0], this.items[i].item[0]) && (this.options.type == 'semi-dynamic' ? !contains(this.element[0], this.items[i].item[0]) : true)) {
                    this.direction = intersection == 1 ? "down": "up";
                    this.rearrange(e, this.items[i]);
                    this.propagate("change", e);
                    break;
                }
            }
            this.contactContainers(e);
            this.propagate("sort", e);
            if (!this.options.axis || this.options.axis == "x") this.helper[0].style.left = this.position.left + 'px';
            if (!this.options.axis || this.options.axis == "y") this.helper[0].style.top = this.position.top + 'px';
            if ($.ui.ddmanager) $.ui.ddmanager.drag(this, e);
            return false;
        },
        rearrange: function(e, i, a, hardRefresh) {
            a ? a.append(this.currentItem) : i.item[this.direction == 'down' ? 'before': 'after'](this.currentItem);
            this.counter = this.counter ? ++this.counter: 1;
            var self = this,
            counter = this.counter;
            window.setTimeout(function() {
                if (counter == self.counter) self.refreshPositions(!hardRefresh);
            },
            0);
            if (this.options.placeholder)
            this.options.placeholder.update.call(this.element, this.currentItem, this.placeholder);
        },
        mouseStop: function(e, noPropagation) {
            if ($.ui.ddmanager && !this.options.dropBehaviour)
            $.ui.ddmanager.drop(this, e);
            if (this.options.revert) {
                var self = this;
                var cur = self.currentItem.offset();
                if (self.placeholder) self.placeholder.animate({
                    opacity: 'hide'
                },
                (parseInt(this.options.revert, 10) || 500) - 50);
                $(this.helper).animate({
                    left: cur.left - this.offset.parent.left - self.margins.left + (this.offsetParent[0] == document.body ? 0: this.offsetParent[0].scrollLeft),
                    top: cur.top - this.offset.parent.top - self.margins.top + (this.offsetParent[0] == document.body ? 0: this.offsetParent[0].scrollTop)
                },
                parseInt(this.options.revert, 10) || 500,
                function() {
                    self.clear(e);
                });
            } else {
                this.clear(e, noPropagation);
            }
            return false;
        },
        clear: function(e, noPropagation) {
            if (this.domPosition.prev != this.currentItem.prev().not(".ui-sortable-helper")[0] || this.domPosition.parent != this.currentItem.parent()[0]) this.propagate("update", e, null, noPropagation);
            if (!contains(this.element[0], this.currentItem[0])) {
                this.propagate("remove", e, null, noPropagation);
                for (var i = this.containers.length - 1; i >= 0; i--) {
                    if (contains(this.containers[i].element[0], this.currentItem[0])) {
                        this.containers[i].propagate("update", e, this, noPropagation);
                        this.containers[i].propagate("receive", e, this, noPropagation);
                    }
                };
            };
            for (var i = this.containers.length - 1; i >= 0; i--) {
                this.containers[i].propagate("deactivate", e, this, noPropagation);
                if (this.containers[i].containerCache.over) {
                    this.containers[i].propagate("out", e, this);
                    this.containers[i].containerCache.over = 0;
                }
            }
            this.dragging = false;
            if (this.cancelHelperRemoval) {
                this.propagate("stop", e, null, noPropagation);
                return false;
            }
            $(this.currentItem).css('visibility', '');
            if (this.placeholder) this.placeholder.remove();
            this.helper.remove();
            this.helper = null;
            this.propagate("stop", e, null, noPropagation);
            return true;
        }
    }));
    $.extend($.ui.sortable, {
        getter: "serialize toArray",
        defaults: {
            helper: "clone",
            tolerance: "guess",
            distance: 1,
            delay: 0,
            scroll: true,
            scrollSensitivity: 20,
            scrollSpeed: 20,
            cancel: ":input",
            items: '> *',
            zIndex: 1000,
            dropOnEmpty: true,
            appendTo: "parent"
        }
    });
    $.ui.plugin.add("sortable", "cursor", {
        start: function(e, ui) {
            var t = $('body');
            if (t.css("cursor")) ui.options._cursor = t.css("cursor");
            t.css("cursor", ui.options.cursor);
        },
        stop: function(e, ui) {
            if (ui.options._cursor) $('body').css("cursor", ui.options._cursor);
        }
    });
    $.ui.plugin.add("sortable", "zIndex", {
        start: function(e, ui) {
            var t = ui.helper;
            if (t.css("zIndex")) ui.options._zIndex = t.css("zIndex");
            t.css('zIndex', ui.options.zIndex);
        },
        stop: function(e, ui) {
            if (ui.options._zIndex) $(ui.helper).css('zIndex', ui.options._zIndex);
        }
    });
    $.ui.plugin.add("sortable", "opacity", {
        start: function(e, ui) {
            var t = ui.helper;
            if (t.css("opacity")) ui.options._opacity = t.css("opacity");
            t.css('opacity', ui.options.opacity);
        },
        stop: function(e, ui) {
            if (ui.options._opacity) $(ui.helper).css('opacity', ui.options._opacity);
        }
    });
    $.ui.plugin.add("sortable", "scroll", {
        start: function(e, ui) {
            var o = ui.options;
            var i = $(this).data("sortable");
            i.overflowY = function(el) {
                do {
                    if (/auto|scroll/.test(el.css('overflow')) || (/auto|scroll/).test(el.css('overflow-y'))) return el;
                    el = el.parent();
                }
                while (el[0].parentNode);
                return $(document);
            } (i.currentItem);
            i.overflowX = function(el) {
                do {
                    if (/auto|scroll/.test(el.css('overflow')) || (/auto|scroll/).test(el.css('overflow-x'))) return el;
                    el = el.parent();
                }
                while (el[0].parentNode);
                return $(document);
            } (i.currentItem);
            if (i.overflowY[0] != document && i.overflowY[0].tagName != 'HTML') i.overflowYOffset = i.overflowY.offset();
            if (i.overflowX[0] != document && i.overflowX[0].tagName != 'HTML') i.overflowXOffset = i.overflowX.offset();
        },
        sort: function(e, ui) {
            var o = ui.options;
            var i = $(this).data("sortable");
            if (i.overflowY[0] != document && i.overflowY[0].tagName != 'HTML') {
                if ((i.overflowYOffset.top + i.overflowY[0].offsetHeight) - e.pageY < o.scrollSensitivity)
                i.overflowY[0].scrollTop = i.overflowY[0].scrollTop + o.scrollSpeed;
                if (e.pageY - i.overflowYOffset.top < o.scrollSensitivity)
                i.overflowY[0].scrollTop = i.overflowY[0].scrollTop - o.scrollSpeed;
            } else {
                if (e.pageY - $(document).scrollTop() < o.scrollSensitivity)
                $(document).scrollTop($(document).scrollTop() - o.scrollSpeed);
                if ($(window).height() - (e.pageY - $(document).scrollTop()) < o.scrollSensitivity)
                $(document).scrollTop($(document).scrollTop() + o.scrollSpeed);
            }
            if (i.overflowX[0] != document && i.overflowX[0].tagName != 'HTML') {
                if ((i.overflowXOffset.left + i.overflowX[0].offsetWidth) - e.pageX < o.scrollSensitivity)
                i.overflowX[0].scrollLeft = i.overflowX[0].scrollLeft + o.scrollSpeed;
                if (e.pageX - i.overflowXOffset.left < o.scrollSensitivity)
                i.overflowX[0].scrollLeft = i.overflowX[0].scrollLeft - o.scrollSpeed;
            } else {
                if (e.pageX - $(document).scrollLeft() < o.scrollSensitivity)
                $(document).scrollLeft($(document).scrollLeft() - o.scrollSpeed);
                if ($(window).width() - (e.pageX - $(document).scrollLeft()) < o.scrollSensitivity)
                $(document).scrollLeft($(document).scrollLeft() + o.scrollSpeed);
            }
        }
    });
})(jQuery); (function($) {
    $.fn.unwrap = $.fn.unwrap ||
    function(expr) {
        return this.each(function() {
            $(this).parents(expr).eq(0).after(this).remove();
        });
    };
    $.widget("ui.slider", {
        plugins: {},
        ui: function(e) {
            return {
                options: this.options,
                handle: this.currentHandle,
                value: this.options.axis != "both" || !this.options.axis ? Math.round(this.value(null, this.options.axis == "vertical" ? "y": "x")) : {
                    x: Math.round(this.value(null, "x")),
                    y: Math.round(this.value(null, "y"))
                },
                range: this.getRange()
            };
        },
        propagate: function(n, e) {
            $.ui.plugin.call(this, n, [e, this.ui()]);
            this.element.triggerHandler(n == "slide" ? n: "slide" + n, [e, this.ui()], this.options[n]);
        },
        destroy: function() {
            this.element.removeClass("ui-slider ui-slider-disabled").removeData("slider").unbind(".slider");
            if (this.handle && this.handle.length) {
                this.handle.unwrap("a");
                this.handle.each(function() {
                    $(this).data("mouse").mouseDestroy();
                });
            }
            this.generated && this.generated.remove();
        },
        setData: function(key, value) {
            $.widget.prototype.setData.apply(this, arguments);
            if (/min|max|steps/.test(key)) {
                this.initBoundaries();
            }
            if (key == "range") {
                value ? this.handle.length == 2 && this.createRange() : this.removeRange();
            }
        },
        init: function() {
            var self = this;
            this.element.addClass("ui-slider");
            this.initBoundaries();
            this.handle = $(this.options.handle, this.element);
            if (!this.handle.length) {
                self.handle = self.generated = $(self.options.handles || [0]).map(function() {
                    var handle = $("<div/>").addClass("ui-slider-handle").appendTo(self.element);
                    if (this.id)
                    handle.attr("id", this.id);
                    return handle[0];
                });
            }
            var handleclass = function(el) {
                this.element = $(el);
                this.element.data("mouse", this);
                this.options = self.options;
                this.element.bind("mousedown",
                function() {
                    if (self.currentHandle) this.blur(self.currentHandle);
                    self.focus(this, 1);
                });
                this.mouseInit();
            };
            $.extend(handleclass.prototype, $.ui.mouse, {
                mouseStart: function(e) {
                    return self.start.call(self, e, this.element[0]);
                },
                mouseStop: function(e) {
                    return self.stop.call(self, e, this.element[0]);
                },
                mouseDrag: function(e) {
                    return self.drag.call(self, e, this.element[0]);
                },
                mouseCapture: function() {
                    return true;
                },
                trigger: function(e) {
                    this.mouseDown(e);
                }
            });
            $(this.handle).each(function() {
                new handleclass(this);
            }).wrap('<a href="javascript:void(0)" style="cursor:default;"></a>').parent().bind('focus',
            function(e) {
                self.focus(this.firstChild);
            }).bind('blur',
            function(e) {
                self.blur(this.firstChild);
            }).bind('keydown',
            function(e) {
                if (!self.options.noKeyboard) self.keydown(e.keyCode, this.firstChild);
            });
            this.element.bind('mousedown.slider',
            function(e) {
                self.click.apply(self, [e]);
                self.currentHandle.data("mouse").trigger(e);
                self.firstValue = self.firstValue + 1;
            });
            $.each(this.options.handles || [],
            function(index, handle) {
                self.moveTo(handle.start, index, true);
            });
            if (!isNaN(this.options.startValue))
            this.moveTo(this.options.startValue, 0, true);
            this.previousHandle = $(this.handle[0]);
            if (this.handle.length == 2 && this.options.range) this.createRange();
        },
        initBoundaries: function() {
            var element = this.element[0],
            o = this.options;
            this.actualSize = {
                width: this.element.outerWidth(),
                height: this.element.outerHeight()
            };
            $.extend(o, {
                axis: o.axis || (element.offsetWidth < element.offsetHeight ? 'vertical': 'horizontal'),
                max: !isNaN(parseInt(o.max, 10)) ? {
                    x: parseInt(o.max, 10),
                    y: parseInt(o.max, 10)
                }: ({
                    x: o.max && o.max.x || 100,
                    y: o.max && o.max.y || 100
                }),
                min: !isNaN(parseInt(o.min, 10)) ? {
                    x: parseInt(o.min, 10),
                    y: parseInt(o.min, 10)
                }: ({
                    x: o.min && o.min.x || 0,
                    y: o.min && o.min.y || 0
                })
            });
            o.realMax = {
                x: o.max.x - o.min.x,
                y: o.max.y - o.min.y
            };
            o.stepping = {
                x: o.stepping && o.stepping.x || parseInt(o.stepping, 10) || (o.steps ? o.realMax.x / (o.steps.x || parseInt(o.steps, 10) || o.realMax.x) : 0),
                y: o.stepping && o.stepping.y || parseInt(o.stepping, 10) || (o.steps ? o.realMax.y / (o.steps.y || parseInt(o.steps, 10) || o.realMax.y) : 0)
            };
        },
        keydown: function(keyCode, handle) {
            if (/(37|38|39|40)/.test(keyCode)) {
                this.moveTo({
                    x: /(37|39)/.test(keyCode) ? (keyCode == 37 ? '-': '+') + '=' + this.oneStep("x") : 0,
                    y: /(38|40)/.test(keyCode) ? (keyCode == 38 ? '-': '+') + '=' + this.oneStep("y") : 0
                },
                handle);
            }
        },
        focus: function(handle, hard) {
            this.currentHandle = $(handle).addClass('ui-slider-handle-active');
            if (hard)
            this.currentHandle.parent()[0].focus();
        },
        blur: function(handle) {
            $(handle).removeClass('ui-slider-handle-active');
            if (this.currentHandle && this.currentHandle[0] == handle) {
                this.previousHandle = this.currentHandle;
                this.currentHandle = null;
            };
        },
        click: function(e) {
            var pointer = [e.pageX, e.pageY];
            var clickedHandle = false;
            this.handle.each(function() {
                if (this == e.target)
                clickedHandle = true;
            });
            if (clickedHandle || this.options.disabled || !(this.currentHandle || this.previousHandle))
            return;
            if (!this.currentHandle && this.previousHandle)
            this.focus(this.previousHandle, true);
            this.offset = this.element.offset();
            this.moveTo({
                y: this.convertValue(e.pageY - this.offset.top - this.currentHandle[0].offsetHeight / 2, "y"),
                x: this.convertValue(e.pageX - this.offset.left - this.currentHandle[0].offsetWidth / 2, "x")
            },
            null, !this.options.distance);
        },
        createRange: function() {
            if (this.rangeElement) return;
            this.rangeElement = $('<div></div>').addClass('ui-slider-range').css({
                position: 'absolute'
            }).appendTo(this.element);
            this.updateRange();
        },
        removeRange: function() {
            this.rangeElement.remove();
            this.rangeElement = null;
        },
        updateRange: function() {
            var prop = this.options.axis == "vertical" ? "top": "left";
            var size = this.options.axis == "vertical" ? "height": "width";
            this.rangeElement.css(prop, (parseInt($(this.handle[0]).css(prop), 10) || 0) + this.handleSize(0, this.options.axis == "vertical" ? "y": "x") / 2);
            this.rangeElement.css(size, (parseInt($(this.handle[1]).css(prop), 10) || 0) - (parseInt($(this.handle[0]).css(prop), 10) || 0));
        },
        getRange: function() {
            return this.rangeElement ? this.convertValue(parseInt(this.rangeElement.css(this.options.axis == "vertical" ? "height": "width"), 10), this.options.axis == "vertical" ? "y": "x") : null;
        },
        handleIndex: function() {
            return this.handle.index(this.currentHandle[0]);
        },
        value: function(handle, axis) {
            if (this.handle.length == 1) this.currentHandle = this.handle;
            if (!axis) axis = this.options.axis == "vertical" ? "y": "x";
            var curHandle = $(handle != undefined && handle !== null ? this.handle[handle] || handle: this.currentHandle);
            if (curHandle.data("mouse").sliderValue) {
                return parseInt(curHandle.data("mouse").sliderValue[axis], 10);
            } else {
                return parseInt(((parseInt(curHandle.css(axis == "x" ? "left": "top"), 10) / (this.actualSize[axis == "x" ? "width": "height"] - this.handleSize(handle, axis))) * this.options.realMax[axis]) + this.options.min[axis], 10);
            }
        },
        convertValue: function(value, axis) {
            return this.options.min[axis] + (value / (this.actualSize[axis == "x" ? "width": "height"] - this.handleSize(null, axis))) * this.options.realMax[axis];
        },
        translateValue: function(value, axis) {
            return ((value - this.options.min[axis]) / this.options.realMax[axis]) * (this.actualSize[axis == "x" ? "width": "height"] - this.handleSize(null, axis));
        },
        translateRange: function(value, axis) {
            if (this.rangeElement) {
                if (this.currentHandle[0] == this.handle[0] && value >= this.translateValue(this.value(1), axis))
                value = this.translateValue(this.value(1, axis) - this.oneStep(axis), axis);
                if (this.currentHandle[0] == this.handle[1] && value <= this.translateValue(this.value(0), axis))
                value = this.translateValue(this.value(0, axis) + this.oneStep(axis), axis);
            }
            if (this.options.handles) {
                var handle = this.options.handles[this.handleIndex()];
                if (value < this.translateValue(handle.min, axis)) {
                    value = this.translateValue(handle.min, axis);
                } else if (value > this.translateValue(handle.max, axis)) {
                    value = this.translateValue(handle.max, axis);
                }
            }
            return value;
        },
        translateLimits: function(value, axis) {
            if (value >= this.actualSize[axis == "x" ? "width": "height"] - this.handleSize(null, axis))
            value = this.actualSize[axis == "x" ? "width": "height"] - this.handleSize(null, axis);
            if (value <= 0)
            value = 0;
            return value;
        },
        handleSize: function(handle, axis) {
            return $(handle != undefined && handle !== null ? this.handle[handle] : this.currentHandle)[0]["offset" + (axis == "x" ? "Width": "Height")];
        },
        oneStep: function(axis) {
            return this.options.stepping[axis] || 1;
        },
        start: function(e, handle) {
            var o = this.options;
            if (o.disabled) return false;
            this.actualSize = {
                width: this.element.outerWidth(),
                height: this.element.outerHeight()
            };
            if (!this.currentHandle)
            this.focus(this.previousHandle, true);
            this.offset = this.element.offset();
            this.handleOffset = this.currentHandle.offset();
            this.clickOffset = {
                top: e.pageY - this.handleOffset.top,
                left: e.pageX - this.handleOffset.left
            };
            this.firstValue = this.value();
            this.propagate('start', e);
            this.drag(e, handle);
            return true;
        },
        stop: function(e) {
            this.propagate('stop', e);
            if (this.firstValue != this.value())
            this.propagate('change', e);
            this.focus(this.currentHandle, true);
            return false;
        },
        drag: function(e, handle) {
            var o = this.options;
            var position = {
                top: e.pageY - this.offset.top - this.clickOffset.top,
                left: e.pageX - this.offset.left - this.clickOffset.left
            };
            if (!this.currentHandle) this.focus(this.previousHandle, true);
            position.left = this.translateLimits(position.left, "x");
            position.top = this.translateLimits(position.top, "y");
            if (o.stepping.x) {
                var value = this.convertValue(position.left, "x");
                value = Math.round(value / o.stepping.x) * o.stepping.x;
                position.left = this.translateValue(value, "x");
            }
            if (o.stepping.y) {
                var value = this.convertValue(position.top, "y");
                value = Math.round(value / o.stepping.y) * o.stepping.y;
                position.top = this.translateValue(value, "y");
            }
            position.left = this.translateRange(position.left, "x");
            position.top = this.translateRange(position.top, "y");
            if (o.axis != "vertical") this.currentHandle.css({
                left: position.left
            });
            if (o.axis != "horizontal") this.currentHandle.css({
                top: position.top
            });
            this.currentHandle.data("mouse").sliderValue = {
                x: Math.round(this.convertValue(position.left, "x")) || 0,
                y: Math.round(this.convertValue(position.top, "y")) || 0
            };
            if (this.rangeElement)
            this.updateRange();
            this.propagate('slide', e);
            return false;
        },
        moveTo: function(value, handle, noPropagation) {
            var o = this.options;
            this.actualSize = {
                width: this.element.outerWidth(),
                height: this.element.outerHeight()
            };
            if (handle == undefined && !this.currentHandle && this.handle.length != 1)
            return false;
            if (handle == undefined && !this.currentHandle)
            handle = 0;
            if (handle != undefined)
            this.currentHandle = this.previousHandle = $(this.handle[handle] || handle);
            if (value.x !== undefined && value.y !== undefined) {
                var x = value.x,
                y = value.y;
            } else {
                var x = value,
                y = value;
            }
            if (x !== undefined && x.constructor != Number) {
                var me = /^\-\=/.test(x),
                pe = /^\+\=/.test(x);
                if (me || pe) {
                    x = this.value(null, "x") + parseInt(x.replace(me ? '=': '+=', ''), 10);
                } else {
                    x = isNaN(parseInt(x, 10)) ? undefined: parseInt(x, 10);
                }
            }
            if (y !== undefined && y.constructor != Number) {
                var me = /^\-\=/.test(y),
                pe = /^\+\=/.test(y);
                if (me || pe) {
                    y = this.value(null, "y") + parseInt(y.replace(me ? '=': '+=', ''), 10);
                } else {
                    y = isNaN(parseInt(y, 10)) ? undefined: parseInt(y, 10);
                }
            }
            if (o.axis != "vertical" && x !== undefined) {
                if (o.stepping.x) x = Math.round(x / o.stepping.x) * o.stepping.x;
                x = this.translateValue(x, "x");
                x = this.translateLimits(x, "x");
                x = this.translateRange(x, "x");
                this.currentHandle.css({
                    left: x
                });
            }
            if (o.axis != "horizontal" && y !== undefined) {
                if (o.stepping.y) y = Math.round(y / o.stepping.y) * o.stepping.y;
                y = this.translateValue(y, "y");
                y = this.translateLimits(y, "y");
                y = this.translateRange(y, "y");
                this.currentHandle.css({
                    top: y
                });
            }
            if (this.rangeElement)
            this.updateRange();
            this.currentHandle.data("mouse").sliderValue = {
                x: Math.round(this.convertValue(x, "x")) || 0,
                y: Math.round(this.convertValue(y, "y")) || 0
            };
            if (!noPropagation) {
                this.propagate('start', null);
                this.propagate('stop', null);
                this.propagate('change', null);
                this.propagate("slide", null);
            }
        }
    });
    $.ui.slider.getter = "value";
    $.ui.slider.defaults = {
        handle: ".ui-slider-handle",
        distance: 1
    };
})(jQuery);; (function($) {
    $.effects = $.effects || {};
    $.extend($.effects, {
        save: function(el, set) {
            for (var i = 0; i < set.length; i++) {
                if (set[i] !== null) $.data(el[0], "ec.storage." + set[i], el[0].style[set[i]]);
            }
        },
        restore: function(el, set) {
            for (var i = 0; i < set.length; i++) {
                if (set[i] !== null) el.css(set[i], $.data(el[0], "ec.storage." + set[i]));
            }
        },
        setMode: function(el, mode) {
            if (mode == 'toggle') mode = el.is(':hidden') ? 'show': 'hide';
            return mode;
        },
        getBaseline: function(origin, original) {
            var y,
            x;
            switch (origin[0]) {
            case 'top':
                y = 0;
                break;
            case 'middle':
                y = 0.5;
                break;
            case 'bottom':
                y = 1;
                break;
            default:
                y = origin[0] / original.height;
            };
            switch (origin[1]) {
            case 'left':
                x = 0;
                break;
            case 'center':
                x = 0.5;
                break;
            case 'right':
                x = 1;
                break;
            default:
                x = origin[1] / original.width;
            };
            return {
                x: x,
                y: y
            };
        },
        createWrapper: function(el) {
            if (el.parent().attr('id') == 'fxWrapper')
            return el;
            var props = {
                width: el.outerWidth({
                    margin: true
                }),
                height: el.outerHeight({
                    margin: true
                }),
                'float': el.css('float')
            };
            el.wrap('<div id="fxWrapper" style="font-size:100%;background:transparent;border:none;margin:0;padding:0"></div>');
            var wrapper = el.parent();
            if (el.css('position') == 'static') {
                wrapper.css({
                    position: 'relative'
                });
                el.css({
                    position: 'relative'
                });
            } else {
                var top = parseInt(el.css('top'), 10);
                if (isNaN(top)) top = 'auto';
                var left = parseInt(el.css('left'), 10);
                if (isNaN(left)) left = 'auto';
                wrapper.css({
                    position: el.css('position'),
                    top: top,
                    left: left,
                    zIndex: el.css('z-index')
                }).show();
                el.css({
                    position: 'relative',
                    top: 0,
                    left: 0
                });
            }
            wrapper.css(props);
            return wrapper;
        },
        removeWrapper: function(el) {
            if (el.parent().attr('id') == 'fxWrapper')
            return el.parent().replaceWith(el);
            return el;
        },
        setTransition: function(el, list, factor, val) {
            val = val || {};
            $.each(list,
            function(i, x) {
                unit = el.cssUnit(x);
                if (unit[0] > 0) val[x] = unit[0] * factor + unit[1];
            });
            return val;
        },
        animateClass: function(value, duration, easing, callback) {
            var cb = (typeof easing == "function" ? easing: (callback ? callback: null));
            var ea = (typeof easing == "object" ? easing: null);
            return this.each(function() {
                var offset = {};
                var that = $(this);
                var oldStyleAttr = that.attr("style") || '';
                if (typeof oldStyleAttr == 'object') oldStyleAttr = oldStyleAttr["cssText"];
                if (value.toggle) {
                    that.hasClass(value.toggle) ? value.remove = value.toggle: value.add = value.toggle;
                }
                var oldStyle = $.extend({},
                (document.defaultView ? document.defaultView.getComputedStyle(this, null) : this.currentStyle));
                if (value.add) that.addClass(value.add);
                if (value.remove) that.removeClass(value.remove);
                var newStyle = $.extend({},
                (document.defaultView ? document.defaultView.getComputedStyle(this, null) : this.currentStyle));
                if (value.add) that.removeClass(value.add);
                if (value.remove) that.addClass(value.remove);
                for (var n in newStyle) {
                    if (typeof newStyle[n] != "function" && newStyle[n] && n.indexOf("Moz") == -1 && n.indexOf("length") == -1 && newStyle[n] != oldStyle[n] && (n.match(/color/i) || (!n.match(/color/i) && !isNaN(parseInt(newStyle[n], 10)))) && (oldStyle.position != "static" || (oldStyle.position == "static" && !n.match(/left|top|bottom|right/)))) offset[n] = newStyle[n];
                }
                that.animate(offset, duration, ea,
                function() {
                    if (typeof $(this).attr("style") == 'object') {
                        $(this).attr("style")["cssText"] = "";
                        $(this).attr("style")["cssText"] = oldStyleAttr;
                    } else $(this).attr("style", oldStyleAttr);
                    if (value.add) $(this).addClass(value.add);
                    if (value.remove) $(this).removeClass(value.remove);
                    if (cb) cb.apply(this, arguments);
                });
            });
        }
    });
    $.fn.extend({
        _show: $.fn.show,
        _hide: $.fn.hide,
        __toggle: $.fn.toggle,
        _addClass: $.fn.addClass,
        _removeClass: $.fn.removeClass,
        _toggleClass: $.fn.toggleClass,
        effect: function(fx, o, speed, callback) {
            return $.effects[fx] ? $.effects[fx].call(this, {
                method: fx,
                options: o || {},
                duration: speed,
                callback: callback
            }) : null;
        },
        show: function() {
            if (!arguments[0] || (arguments[0].constructor == Number || /(slow|normal|fast)/.test(arguments[0])))
            return this._show.apply(this, arguments);
            else {
                var o = arguments[1] || {};
                o['mode'] = 'show';
                return this.effect.apply(this, [arguments[0], o, arguments[2] || o.duration, arguments[3] || o.callback]);
            }
        },
        hide: function() {
            if (!arguments[0] || (arguments[0].constructor == Number || /(slow|normal|fast)/.test(arguments[0])))
            return this._hide.apply(this, arguments);
            else {
                var o = arguments[1] || {};
                o['mode'] = 'hide';
                return this.effect.apply(this, [arguments[0], o, arguments[2] || o.duration, arguments[3] || o.callback]);
            }
        },
        toggle: function() {
            if (!arguments[0] || (arguments[0].constructor == Number || /(slow|normal|fast)/.test(arguments[0])) || (arguments[0].constructor == Function))
            return this.__toggle.apply(this, arguments);
            else {
                var o = arguments[1] || {};
                o['mode'] = 'toggle';
                return this.effect.apply(this, [arguments[0], o, arguments[2] || o.duration, arguments[3] || o.callback]);
            }
        },
        addClass: function(classNames, speed, easing, callback) {
            return speed ? $.effects.animateClass.apply(this, [{
                add: classNames
            },
            speed, easing, callback]) : this._addClass(classNames);
        },
        removeClass: function(classNames, speed, easing, callback) {
            return speed ? $.effects.animateClass.apply(this, [{
                remove: classNames
            },
            speed, easing, callback]) : this._removeClass(classNames);
        },
        toggleClass: function(classNames, speed, easing, callback) {
            return speed ? $.effects.animateClass.apply(this, [{
                toggle: classNames
            },
            speed, easing, callback]) : this._toggleClass(classNames);
        },
        morph: function(remove, add, speed, easing, callback) {
            return $.effects.animateClass.apply(this, [{
                add: add,
                remove: remove
            },
            speed, easing, callback]);
        },
        switchClass: function() {
            return this.morph.apply(this, arguments);
        },
        cssUnit: function(key) {
            var style = this.css(key),
            val = [];
            $.each(['em', 'px', '%', 'pt'],
            function(i, unit) {
                if (style.indexOf(unit) > 0)
                val = [parseFloat(style), unit];
            });
            return val;
        }
    });
    jQuery.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'],
    function(i, attr) {
        jQuery.fx.step[attr] = function(fx) {
            if (fx.state == 0) {
                fx.start = getColor(fx.elem, attr);
                fx.end = getRGB(fx.end);
            }
            fx.elem.style[attr] = "rgb(" + [Math.max(Math.min(parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0]), 255), 0), Math.max(Math.min(parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1]), 255), 0), Math.max(Math.min(parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2]), 255), 0)].join(",") + ")";
        }
    });
    function getRGB(color) {
        var result;
        if (color && color.constructor == Array && color.length == 3)
        return color;
        if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
        return [parseInt(result[1]), parseInt(result[2]), parseInt(result[3])];
        if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
        return [parseFloat(result[1]) * 2.55, parseFloat(result[2]) * 2.55, parseFloat(result[3]) * 2.55];
        if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
        return [parseInt(result[1], 16), parseInt(result[2], 16), parseInt(result[3], 16)];
        if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
        return [parseInt(result[1] + result[1], 16), parseInt(result[2] + result[2], 16), parseInt(result[3] + result[3], 16)];
        if (result = /rgba\(0, 0, 0, 0\)/.exec(color))
        return colors['transparent']
        return colors[jQuery.trim(color).toLowerCase()];
    }
    function getColor(elem, attr) {
        var color;
        do {
            color = jQuery.curCSS(elem, attr);
            if (color != '' && color != 'transparent' || jQuery.nodeName(elem, "body"))
            break;
            attr = "backgroundColor";
        }
        while (elem = elem.parentNode);
        return getRGB(color);
    };
    var colors = {
        aqua: [0, 255, 255],
        azure: [240, 255, 255],
        beige: [245, 245, 220],
        black: [0, 0, 0],
        blue: [0, 0, 255],
        brown: [165, 42, 42],
        cyan: [0, 255, 255],
        darkblue: [0, 0, 139],
        darkcyan: [0, 139, 139],
        darkgrey: [169, 169, 169],
        darkgreen: [0, 100, 0],
        darkkhaki: [189, 183, 107],
        darkmagenta: [139, 0, 139],
        darkolivegreen: [85, 107, 47],
        darkorange: [255, 140, 0],
        darkorchid: [153, 50, 204],
        darkred: [139, 0, 0],
        darksalmon: [233, 150, 122],
        darkviolet: [148, 0, 211],
        fuchsia: [255, 0, 255],
        gold: [255, 215, 0],
        green: [0, 128, 0],
        indigo: [75, 0, 130],
        khaki: [240, 230, 140],
        lightblue: [173, 216, 230],
        lightcyan: [224, 255, 255],
        lightgreen: [144, 238, 144],
        lightgrey: [211, 211, 211],
        lightpink: [255, 182, 193],
        lightyellow: [255, 255, 224],
        lime: [0, 255, 0],
        magenta: [255, 0, 255],
        maroon: [128, 0, 0],
        navy: [0, 0, 128],
        olive: [128, 128, 0],
        orange: [255, 165, 0],
        pink: [255, 192, 203],
        purple: [128, 0, 128],
        violet: [128, 0, 128],
        red: [255, 0, 0],
        silver: [192, 192, 192],
        white: [255, 255, 255],
        yellow: [255, 255, 0],
        transparent: [255, 255, 255]
    };
    jQuery.easing['jswing'] = jQuery.easing['swing'];
    jQuery.extend(jQuery.easing, {
        def: 'easeOutQuad',
        swing: function(x, t, b, c, d) {
            return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
        },
        easeInQuad: function(x, t, b, c, d) {
            return c * (t /= d) * t + b;
        },
        easeOutQuad: function(x, t, b, c, d) {
            return - c * (t /= d) * (t - 2) + b;
        },
        easeInOutQuad: function(x, t, b, c, d) {
            if ((t /= d / 2) < 1) return c / 2 * t * t + b;
            return - c / 2 * ((--t) * (t - 2) - 1) + b;
        },
        easeInCubic: function(x, t, b, c, d) {
            return c * (t /= d) * t * t + b;
        },
        easeOutCubic: function(x, t, b, c, d) {
            return c * ((t = t / d - 1) * t * t + 1) + b;
        },
        easeInOutCubic: function(x, t, b, c, d) {
            if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
            return c / 2 * ((t -= 2) * t * t + 2) + b;
        },
        easeInQuart: function(x, t, b, c, d) {
            return c * (t /= d) * t * t * t + b;
        },
        easeOutQuart: function(x, t, b, c, d) {
            return - c * ((t = t / d - 1) * t * t * t - 1) + b;
        },
        easeInOutQuart: function(x, t, b, c, d) {
            if ((t /= d / 2) < 1) return c / 2 * t * t * t * t + b;
            return - c / 2 * ((t -= 2) * t * t * t - 2) + b;
        },
        easeInQuint: function(x, t, b, c, d) {
            return c * (t /= d) * t * t * t * t + b;
        },
        easeOutQuint: function(x, t, b, c, d) {
            return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
        },
        easeInOutQuint: function(x, t, b, c, d) {
            if ((t /= d / 2) < 1) return c / 2 * t * t * t * t * t + b;
            return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
        },
        easeInSine: function(x, t, b, c, d) {
            return - c * Math.cos(t / d * (Math.PI / 2)) + c + b;
        },
        easeOutSine: function(x, t, b, c, d) {
            return c * Math.sin(t / d * (Math.PI / 2)) + b;
        },
        easeInOutSine: function(x, t, b, c, d) {
            return - c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
        },
        easeInExpo: function(x, t, b, c, d) {
            return (t == 0) ? b: c * Math.pow(2, 10 * (t / d - 1)) + b;
        },
        easeOutExpo: function(x, t, b, c, d) {
            return (t == d) ? b + c: c * ( - Math.pow(2, -10 * t / d) + 1) + b;
        },
        easeInOutExpo: function(x, t, b, c, d) {
            if (t == 0) return b;
            if (t == d) return b + c;
            if ((t /= d / 2) < 1) return c / 2 * Math.pow(2, 10 * (t - 1)) + b;
            return c / 2 * ( - Math.pow(2, -10 * --t) + 2) + b;
        },
        easeInCirc: function(x, t, b, c, d) {
            return - c * (Math.sqrt(1 - (t /= d) * t) - 1) + b;
        },
        easeOutCirc: function(x, t, b, c, d) {
            return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
        },
        easeInOutCirc: function(x, t, b, c, d) {
            if ((t /= d / 2) < 1) return - c / 2 * (Math.sqrt(1 - t * t) - 1) + b;
            return c / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
        },
        easeInElastic: function(x, t, b, c, d) {
            var s = 1.70158;
            var p = 0;
            var a = c;
            if (t == 0) return b;
            if ((t /= d) == 1) return b + c;
            if (!p) p = d * .3;
            if (a < Math.abs(c)) {
                a = c;
                var s = p / 4;
            }
            else var s = p / (2 * Math.PI) * Math.asin(c / a);
            return - (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
        },
        easeOutElastic: function(x, t, b, c, d) {
            var s = 1.70158;
            var p = 0;
            var a = c;
            if (t == 0) return b;
            if ((t /= d) == 1) return b + c;
            if (!p) p = d * .3;
            if (a < Math.abs(c)) {
                a = c;
                var s = p / 4;
            }
            else var s = p / (2 * Math.PI) * Math.asin(c / a);
            return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
        },
        easeInOutElastic: function(x, t, b, c, d) {
            var s = 1.70158;
            var p = 0;
            var a = c;
            if (t == 0) return b;
            if ((t /= d / 2) == 2) return b + c;
            if (!p) p = d * (.3 * 1.5);
            if (a < Math.abs(c)) {
                a = c;
                var s = p / 4;
            }
            else var s = p / (2 * Math.PI) * Math.asin(c / a);
            if (t < 1) return - .5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
            return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p) * .5 + c + b;
        },
        easeInBack: function(x, t, b, c, d, s) {
            if (s == undefined) s = 1.70158;
            return c * (t /= d) * t * ((s + 1) * t - s) + b;
        },
        easeOutBack: function(x, t, b, c, d, s) {
            if (s == undefined) s = 1.70158;
            return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
        },
        easeInOutBack: function(x, t, b, c, d, s) {
            if (s == undefined) s = 1.70158;
            if ((t /= d / 2) < 1) return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
            return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
        },
        easeInBounce: function(x, t, b, c, d) {
            return c - jQuery.easing.easeOutBounce(x, d - t, 0, c, d) + b;
        },
        easeOutBounce: function(x, t, b, c, d) {
            if ((t /= d) < (1 / 2.75)) {
                return c * (7.5625 * t * t) + b;
            } else if (t < (2 / 2.75)) {
                return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
            } else if (t < (2.5 / 2.75)) {
                return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
            } else {
                return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
            }
        },
        easeInOutBounce: function(x, t, b, c, d) {
            if (t < d / 2) return jQuery.easing.easeInBounce(x, t * 2, 0, c, d) * .5 + b;
            return jQuery.easing.easeOutBounce(x, t * 2 - d, 0, c, d) * .5 + c * .5 + b;
        }
    });
})(jQuery); (function($) {
    $.effects.blind = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left'];
            var mode = $.effects.setMode(el, o.options.mode || 'hide');
            var direction = o.options.direction || 'vertical';
            $.effects.save(el, props);
            el.show();
            var wrapper = $.effects.createWrapper(el).css({
                overflow: 'hidden'
            });
            var ref = (direction == 'vertical') ? 'height': 'width';
            var distance = (direction == 'vertical') ? wrapper.height() : wrapper.width();
            if (mode == 'show') wrapper.css(ref, 0);
            var animation = {};
            animation[ref] = mode == 'show' ? distance: 0;
            wrapper.animate(animation, o.duration, o.options.easing,
            function() {
                if (mode == 'hide') el.hide();
                $.effects.restore(el, props);
                $.effects.removeWrapper(el);
                if (o.callback) o.callback.apply(el[0], arguments);
                el.dequeue();
            });
        });
    };
})(jQuery); (function($) {
    $.effects.bounce = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left'];
            var mode = $.effects.setMode(el, o.options.mode || 'effect');
            var direction = o.options.direction || 'up';
            var distance = o.options.distance || 20;
            var times = o.options.times || 5;
            var speed = o.duration || 250;
            if (/show|hide/.test(mode)) props.push('opacity');
            $.effects.save(el, props);
            el.show();
            $.effects.createWrapper(el);
            var ref = (direction == 'up' || direction == 'down') ? 'top': 'left';
            var motion = (direction == 'up' || direction == 'left') ? 'pos': 'neg';
            var distance = o.options.distance || (ref == 'top' ? el.outerHeight({
                margin: true
            }) / 3: el.outerWidth({
                margin: true
            }) / 3);
            if (mode == 'show') el.css('opacity', 0).css(ref, motion == 'pos' ? -distance: distance);
            if (mode == 'hide') distance = distance / (times * 2);
            if (mode != 'hide') times--;
            if (mode == 'show') {
                var animation = {
                    opacity: 1
                };
                animation[ref] = (motion == 'pos' ? '+=': '-=') + distance;
                el.animate(animation, speed / 2, o.options.easing);
                distance = distance / 2;
                times--;
            };
            for (var i = 0; i < times; i++) {
                var animation1 = {},
                animation2 = {};
                animation1[ref] = (motion == 'pos' ? '-=': '+=') + distance;
                animation2[ref] = (motion == 'pos' ? '+=': '-=') + distance;
                el.animate(animation1, speed / 2, o.options.easing).animate(animation2, speed / 2, o.options.easing);
                distance = (mode == 'hide') ? distance * 2: distance / 2;
            };
            if (mode == 'hide') {
                var animation = {
                    opacity: 0
                };
                animation[ref] = (motion == 'pos' ? '-=': '+=') + distance;
                el.animate(animation, speed / 2, o.options.easing,
                function() {
                    el.hide();
                    $.effects.restore(el, props);
                    $.effects.removeWrapper(el);
                    if (o.callback) o.callback.apply(this, arguments);
                });
            } else {
                var animation1 = {},
                animation2 = {};
                animation1[ref] = (motion == 'pos' ? '-=': '+=') + distance;
                animation2[ref] = (motion == 'pos' ? '+=': '-=') + distance;
                el.animate(animation1, speed / 2, o.options.easing).animate(animation2, speed / 2, o.options.easing,
                function() {
                    $.effects.restore(el, props);
                    $.effects.removeWrapper(el);
                    if (o.callback) o.callback.apply(this, arguments);
                });
            };
            el.queue('fx',
            function() {
                el.dequeue();
            });
            el.dequeue();
        });
    };
})(jQuery); (function($) {
    $.effects.clip = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left', 'height', 'width'];
            var mode = $.effects.setMode(el, o.options.mode || 'hide');
            var direction = o.options.direction || 'vertical';
            $.effects.save(el, props);
            el.show();
            var wrapper = $.effects.createWrapper(el).css({
                overflow: 'hidden'
            });
            var animate = el[0].tagName == 'IMG' ? wrapper: el;
            var ref = {
                size: (direction == 'vertical') ? 'height': 'width',
                position: (direction == 'vertical') ? 'top': 'left'
            };
            var distance = (direction == 'vertical') ? animate.height() : animate.width();
            if (mode == 'show') {
                animate.css(ref.size, 0);
                animate.css(ref.position, distance / 2);
            }
            var animation = {};
            animation[ref.size] = mode == 'show' ? distance: 0;
            animation[ref.position] = mode == 'show' ? 0: distance / 2;
            animate.animate(animation, {
                queue: false,
                duration: o.duration,
                easing: o.options.easing,
                complete: function() {
                    if (mode == 'hide') el.hide();
                    $.effects.restore(el, props);
                    $.effects.removeWrapper(el);
                    if (o.callback) o.callback.apply(el[0], arguments);
                    el.dequeue();
                }
            });
        });
    };
})(jQuery); (function($) {
    $.effects.drop = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left', 'opacity'];
            var mode = $.effects.setMode(el, o.options.mode || 'hide');
            var direction = o.options.direction || 'left';
            $.effects.save(el, props);
            el.show();
            $.effects.createWrapper(el);
            var ref = (direction == 'up' || direction == 'down') ? 'top': 'left';
            var motion = (direction == 'up' || direction == 'left') ? 'pos': 'neg';
            var distance = o.options.distance || (ref == 'top' ? el.outerHeight({
                margin: true
            }) / 2: el.outerWidth({
                margin: true
            }) / 2);
            if (mode == 'show') el.css('opacity', 0).css(ref, motion == 'pos' ? -distance: distance);
            var animation = {
                opacity: mode == 'show' ? 1: 0
            };
            animation[ref] = (mode == 'show' ? (motion == 'pos' ? '+=': '-=') : (motion == 'pos' ? '-=': '+=')) + distance;
            el.animate(animation, {
                queue: false,
                duration: o.duration,
                easing: o.options.easing,
                complete: function() {
                    if (mode == 'hide') el.hide();
                    $.effects.restore(el, props);
                    $.effects.removeWrapper(el);
                    if (o.callback) o.callback.apply(this, arguments);
                    el.dequeue();
                }
            });
        });
    };
})(jQuery); (function($) {
    $.effects.fold = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left'];
            var mode = $.effects.setMode(el, o.options.mode || 'hide');
            var size = o.options.size || 15;
            var horizFirst = !(!o.options.horizFirst);
            $.effects.save(el, props);
            el.show();
            var wrapper = $.effects.createWrapper(el).css({
                overflow: 'hidden'
            });
            var widthFirst = ((mode == 'show') != horizFirst);
            var ref = widthFirst ? ['width', 'height'] : ['height', 'width'];
            var distance = widthFirst ? [wrapper.width(), wrapper.height()] : [wrapper.height(), wrapper.width()];
            var percent = /([0-9]+)%/.exec(size);
            if (percent) size = parseInt(percent[1]) / 100 * distance[mode == 'hide' ? 0: 1];
            if (mode == 'show') wrapper.css(horizFirst ? {
                height: 0,
                width: size
            }: {
                height: size,
                width: 0
            });
            var animation1 = {},
            animation2 = {};
            animation1[ref[0]] = mode == 'show' ? distance[0] : size;
            animation2[ref[1]] = mode == 'show' ? distance[1] : 0;
            wrapper.animate(animation1, o.duration / 2, o.options.easing).animate(animation2, o.duration / 2, o.options.easing,
            function() {
                if (mode == 'hide') el.hide();
                $.effects.restore(el, props);
                $.effects.removeWrapper(el);
                if (o.callback) o.callback.apply(el[0], arguments);
                el.dequeue();
            });
        });
    };
})(jQuery);; (function($) {
    $.effects.highlight = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['backgroundImage', 'backgroundColor', 'opacity'];
            var mode = $.effects.setMode(el, o.options.mode || 'show');
            var color = o.options.color || "#ffff99";
            var oldColor = el.css("backgroundColor");
            $.effects.save(el, props);
            el.show();
            el.css({
                backgroundImage: 'none',
                backgroundColor: color
            });
            var animation = {
                backgroundColor: oldColor
            };
            if (mode == "hide") animation['opacity'] = 0;
            el.animate(animation, {
                queue: false,
                duration: o.duration,
                easing: o.options.easing,
                complete: function() {
                    if (mode == "hide") el.hide();
                    $.effects.restore(el, props);
                    if (mode == "show" && jQuery.browser.msie) this.style.removeAttribute('filter');
                    if (o.callback) o.callback.apply(this, arguments);
                    el.dequeue();
                }
            });
        });
    };
})(jQuery); (function($) {
    $.effects.pulsate = function(o) {
        return this.queue(function() {
            var el = $(this);
            var mode = $.effects.setMode(el, o.options.mode || 'show');
            var times = o.options.times || 5;
            if (mode == 'hide') times--;
            if (el.is(':hidden')) {
                el.css('opacity', 0);
                el.show();
                el.animate({
                    opacity: 1
                },
                o.duration / 2, o.options.easing);
                times = times - 2;
            }
            for (var i = 0; i < times; i++) {
                el.animate({
                    opacity: 0
                },
                o.duration / 2, o.options.easing).animate({
                    opacity: 1
                },
                o.duration / 2, o.options.easing);
            };
            if (mode == 'hide') {
                el.animate({
                    opacity: 0
                },
                o.duration / 2, o.options.easing,
                function() {
                    el.hide();
                    if (o.callback) o.callback.apply(this, arguments);
                });
            } else {
                el.animate({
                    opacity: 0
                },
                o.duration / 2, o.options.easing).animate({
                    opacity: 1
                },
                o.duration / 2, o.options.easing,
                function() {
                    if (o.callback) o.callback.apply(this, arguments);
                });
            };
            el.queue('fx',
            function() {
                el.dequeue();
            });
            el.dequeue();
        });
    };
})(jQuery); (function($) {
    $.effects.puff = function(o) {
        return this.queue(function() {
            var el = $(this);
            var options = $.extend(true, {},
            o.options);
            var mode = $.effects.setMode(el, o.options.mode || 'hide');
            var percent = parseInt(o.options.percent) || 150;
            options.fade = true;
            var original = {
                height: el.height(),
                width: el.width()
            };
            var factor = percent / 100;
            el.from = (mode == 'hide') ? original: {
                height: original.height * factor,
                width: original.width * factor
            };
            options.from = el.from;
            options.percent = (mode == 'hide') ? percent: 100;
            options.mode = mode;
            el.effect('scale', options, o.duration, o.callback);
            el.dequeue();
        });
    };
    $.effects.scale = function(o) {
        return this.queue(function() {
            var el = $(this);
            var options = $.extend(true, {},
            o.options);
            var mode = $.effects.setMode(el, o.options.mode || 'effect');
            var percent = parseInt(o.options.percent) || (parseInt(o.options.percent) == 0 ? 0: (mode == 'hide' ? 0: 100));
            var direction = o.options.direction || 'both';
            var origin = o.options.origin;
            if (mode != 'effect') {
                options.origin = origin || ['middle', 'center'];
                options.restore = true;
            }
            var original = {
                height: el.height(),
                width: el.width()
            };
            el.from = o.options.from || (mode == 'show' ? {
                height: 0,
                width: 0
            }: original);
            var factor = {
                y: direction != 'horizontal' ? (percent / 100) : 1,
                x: direction != 'vertical' ? (percent / 100) : 1
            };
            el.to = {
                height: original.height * factor.y,
                width: original.width * factor.x
            };
            if (o.options.fade) {
                if (mode == 'show') {
                    el.from.opacity = 0;
                    el.to.opacity = 1;
                };
                if (mode == 'hide') {
                    el.from.opacity = 1;
                    el.to.opacity = 0;
                };
            };
            options.from = el.from;
            options.to = el.to;
            options.mode = mode;
            el.effect('size', options, o.duration, o.callback);
            el.dequeue();
        });
    };
    $.effects.size = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left', 'width', 'height', 'overflow', 'opacity'];
            var props1 = ['position', 'top', 'left', 'overflow', 'opacity'];
            var props2 = ['width', 'height', 'overflow'];
            var cProps = ['fontSize'];
            var vProps = ['borderTopWidth', 'borderBottomWidth', 'paddingTop', 'paddingBottom'];
            var hProps = ['borderLeftWidth', 'borderRightWidth', 'paddingLeft', 'paddingRight'];
            var mode = $.effects.setMode(el, o.options.mode || 'effect');
            var restore = o.options.restore || false;
            var scale = o.options.scale || 'both';
            var origin = o.options.origin;
            var original = {
                height: el.height(),
                width: el.width()
            };
            el.from = o.options.from || original;
            el.to = o.options.to || original;
            if (origin) {
                var baseline = $.effects.getBaseline(origin, original);
                el.from.top = (original.height - el.from.height) * baseline.y;
                el.from.left = (original.width - el.from.width) * baseline.x;
                el.to.top = (original.height - el.to.height) * baseline.y;
                el.to.left = (original.width - el.to.width) * baseline.x;
            };
            var factor = {
                from: {
                    y: el.from.height / original.height,
                    x: el.from.width / original.width
                },
                to: {
                    y: el.to.height / original.height,
                    x: el.to.width / original.width
                }
            };
            if (scale == 'box' || scale == 'both') {
                if (factor.from.y != factor.to.y) {
                    props = props.concat(vProps);
                    el.from = $.effects.setTransition(el, vProps, factor.from.y, el.from);
                    el.to = $.effects.setTransition(el, vProps, factor.to.y, el.to);
                };
                if (factor.from.x != factor.to.x) {
                    props = props.concat(hProps);
                    el.from = $.effects.setTransition(el, hProps, factor.from.x, el.from);
                    el.to = $.effects.setTransition(el, hProps, factor.to.x, el.to);
                };
            };
            if (scale == 'content' || scale == 'both') {
                if (factor.from.y != factor.to.y) {
                    props = props.concat(cProps);
                    el.from = $.effects.setTransition(el, cProps, factor.from.y, el.from);
                    el.to = $.effects.setTransition(el, cProps, factor.to.y, el.to);
                };
            };
            $.effects.save(el, restore ? props: props1);
            el.show();
            $.effects.createWrapper(el);
            el.css('overflow', 'hidden').css(el.from);
            if (scale == 'content' || scale == 'both') {
                vProps = vProps.concat(['marginTop', 'marginBottom']).concat(cProps);
                hProps = hProps.concat(['marginLeft', 'marginRight']);
                props2 = props.concat(vProps).concat(hProps);
                el.find("*[width]").each(function() {
                    child = $(this);
                    if (restore) $.effects.save(child, props2);
                    var c_original = {
                        height: child.height(),
                        width: child.width()
                    };
                    child.from = {
                        height: c_original.height * factor.from.y,
                        width: c_original.width * factor.from.x
                    };
                    child.to = {
                        height: c_original.height * factor.to.y,
                        width: c_original.width * factor.to.x
                    };
                    if (factor.from.y != factor.to.y) {
                        child.from = $.effects.setTransition(child, vProps, factor.from.y, child.from);
                        child.to = $.effects.setTransition(child, vProps, factor.to.y, child.to);
                    };
                    if (factor.from.x != factor.to.x) {
                        child.from = $.effects.setTransition(child, hProps, factor.from.x, child.from);
                        child.to = $.effects.setTransition(child, hProps, factor.to.x, child.to);
                    };
                    child.css(child.from);
                    child.animate(child.to, o.duration, o.options.easing,
                    function() {
                        if (restore) $.effects.restore(child, props2);
                    });
                });
            };
            el.animate(el.to, {
                queue: false,
                duration: o.duration,
                easing: o.options.easing,
                complete: function() {
                    if (mode == 'hide') el.hide();
                    $.effects.restore(el, restore ? props: props1);
                    $.effects.removeWrapper(el);
                    if (o.callback) o.callback.apply(this, arguments);
                    el.dequeue();
                }
            });
        });
    };
})(jQuery); (function($) {
    $.effects.shake = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left'];
            var mode = $.effects.setMode(el, o.options.mode || 'effect');
            var direction = o.options.direction || 'left';
            var distance = o.options.distance || 20;
            var times = o.options.times || 3;
            var speed = o.duration || o.options.duration || 140;
            $.effects.save(el, props);
            el.show();
            $.effects.createWrapper(el);
            var ref = (direction == 'up' || direction == 'down') ? 'top': 'left';
            var motion = (direction == 'up' || direction == 'left') ? 'pos': 'neg';
            var animation = {},
            animation1 = {},
            animation2 = {};
            animation[ref] = (motion == 'pos' ? '-=': '+=') + distance;
            animation1[ref] = (motion == 'pos' ? '+=': '-=') + distance * 2;
            animation2[ref] = (motion == 'pos' ? '-=': '+=') + distance * 2;
            el.animate(animation, speed, o.options.easing);
            for (var i = 1; i < times; i++) {
                el.animate(animation1, speed, o.options.easing).animate(animation2, speed, o.options.easing);
            };
            el.animate(animation1, speed, o.options.easing).animate(animation, speed / 2, o.options.easing,
            function() {
                $.effects.restore(el, props);
                $.effects.removeWrapper(el);
                if (o.callback) o.callback.apply(this, arguments);
            });
            el.queue('fx',
            function() {
                el.dequeue();
            });
            el.dequeue();
        });
    };
})(jQuery); (function($) {
    $.effects.slide = function(o) {
        return this.queue(function() {
            var el = $(this),
            props = ['position', 'top', 'left'];
            var mode = $.effects.setMode(el, o.options.mode || 'show');
            var direction = o.options.direction || 'left';
            $.effects.save(el, props);
            el.show();
            $.effects.createWrapper(el).css({
                overflow: 'hidden'
            });
            var ref = (direction == 'up' || direction == 'down') ? 'top': 'left';
            var motion = (direction == 'up' || direction == 'left') ? 'pos': 'neg';
            var distance = o.options.distance || (ref == 'top' ? el.outerHeight({
                margin: true
            }) : el.outerWidth({
                margin: true
            }));
            if (mode == 'show') el.css(ref, motion == 'pos' ? -distance: distance);
            var animation = {};
            animation[ref] = (mode == 'show' ? (motion == 'pos' ? '+=': '-=') : (motion == 'pos' ? '-=': '+=')) + distance;
            el.animate(animation, {
                queue: false,
                duration: o.duration,
                easing: o.options.easing,
                complete: function() {
                    if (mode == 'hide') el.hide();
                    $.effects.restore(el, props);
                    $.effects.removeWrapper(el);
                    if (o.callback) o.callback.apply(this, arguments);
                    el.dequeue();
                }
            });
        });
    };
})(jQuery);