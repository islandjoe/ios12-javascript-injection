var Action = function() {};

Action.prototype = {

  run: function(parameters) {
    parameters.completionFunction({
      "URL": document.URL,
      "title": document.title,
      "script": parameters["customJavaScript"]
    });
  },

  finalize: function(parameters) {
    var customJavaScript = parameters["customJavaScript"];

    eval(customJavaScript);
  }

};

var ExtensionPreprocessingJS = new Action
