describe('MRAID', function() {
  var MRAID, BRIDGE;

  beforeEach(function() {
    MRAID = mraid;
    BRIDGE = mraidbridge;
  });

  describe('.resize', function() {
    var errorSpy;

    beforeEach(function() {
      spyOn(BRIDGE, 'executeNativeCall');
      errorSpy = jasmine.createSpy();
      MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
      MRAID.resize();
    });

    afterEach(function() {
      MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
    });

    it('throws an error and does not execute native call', function() {
      expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
      expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'resize');
    });
  });
});
