$("#gene").selectize({
    onFocus : function () {
        console.log("I got here");
        $activeSelect = $select[0].selectize;
        $value = $activeSelect.getValue();
        if ($value.length > 0) {
            $activeSelect.clear(silent = true);
        }
    },

    onType : function(str) {
        console.log("I got here");
    }
});
