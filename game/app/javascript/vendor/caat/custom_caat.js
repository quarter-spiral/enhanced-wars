CAAT.Module.Initialization.Template.extend(
    {},
    {
        init: function( width, height, runHere, imagesURL, onEndLoading )   {

            var canvascontainer= document.getElementById(runHere);
            var director;

            if ( CAAT.__CSS__ ) {   // css renderer
                if ( canvascontainer ) {
                    if ( false===canvascontainer instanceof HTMLDivElement ) {
                        canvascontainer= null;
                    }
                }

                if ( canvascontainer===null ) {
                    canvascontainer= document.createElement('div'); // create a new DIV
                    document.body.appendChild(canvascontainer);
                }

                director= new CAAT.Foundation.Director().
                    initialize(
                        width||800,
                        height||600,
                        canvascontainer);

            } else {

                if ( canvascontainer ) {
                    if ( canvascontainer instanceof HTMLDivElement ) {
                        var ncanvascontainer= document.createElement("canvas");
                        canvascontainer.appendChild(ncanvascontainer);
                        canvascontainer= ncanvascontainer;
                    } else if ( false==canvascontainer instanceof HTMLCanvasElement ) {
                        var ncanvascontainer= document.createElement("canvas");
                        document.body.appendChild(ncanvascontainer);
                        canvascontainer= ncanvascontainer;
                    }
                } else {
                    canvascontainer= document.createElement('canvas');
                    document.body.appendChild(canvascontainer);
                }

                director= new CAAT.Foundation.Director().
                        initialize(
                            width||800,
                            height||600,
                            canvascontainer);
            }

            /**
             * Load splash images. It is supossed the splash has some images.
             */
            new CAAT.Module.Preloader.ImagePreloader().loadImages(
                imagesURL,
                function on_load( counter, images ) {

                    if ( counter===images.length ) {

                        director.emptyScenes();
                        director.setImagesCache(images);

                        onEndLoading(director);

                        /**
                         * Change this sentence's parameters to play with different entering-scene
                         * curtains.
                         * just perform a director.setScene(0) to play first director's scene.
                         */
                        director.setScene(0)

                        CAAT.loop(60);

                    }
                }
            );

        }
    },
    "CAAT.Module.Initialization.QSTemplate",
    [],
    true
);