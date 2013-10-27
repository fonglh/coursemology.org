function MaterialsFilePicker(callback) {
  this.doneCallback = callback;
  this.selectedMaterials = {};
  this.treeElement = $('#file-picker-tree');
  
  var courseId = gon.course;
  var that = this;
  $.ajax({
    url: '/courses/' + courseId + '/materials.json',
    success: that.onWorkbinStructureReceived
  });
}

MaterialsFilePicker.prototype.onSelectionCompleted = function() {
  var selectedItems = [];
  for (var id in selectedMaterials) {
    var currentTuple = selectedMaterials[id];
    selectedItems.push(currentTuple);
  }
  
  this.doneCallback(selectedItems);
};

MaterialsFilePicker.prototype.onWorkbinStructureReceived = function(rootNode) {
  var shouldIncludeFiles = true;
  var treeData = parseFileJsonForJqTree(rootNode, shouldIncludeFiles);
  
  treeElement.tree({
    data: treeData,
    autoOpen: true,
    keyboardSupport: false    
  });
};

MaterialsFilePicker.prototype.onNodeClicked = function(event) {
  // Disable single selection: click to select for everything.
  event.preventDefault();
  
  var selectedNode = event.node;
  var nodeId = selectedNode.id;
  
  var isNodeSelected = treeElement.tree('isNodeSelected', selectedNode);
  var isNodeAFile = nodeId.indexOf("file") !== -1;
  
  // We don't bother with folders - only individual files.
  if (isNodeAFile) {
    var indexAfterPrefix = nodeId.indexOf("_") + 1;
    var id = nodeId.slice(indexAfterPrefix);
    
    // <ID, Type, Name, URL>
    if (isNodeSelected) {
      treeElement.tree('removeFromSelection', selectedNode);
      
      var tuple = [id, "Material", selectedNode.label, selectedNode.url];
      selectedMaterials[id] = tuple;
    } else {
      treeElement.tree('addToSelection', selectedNode);
      delete selectedMaterials[id];
    }
  }
};