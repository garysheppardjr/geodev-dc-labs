package com.esri.wdc.geodev201611;

import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.ArcGISScene;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.mapping.view.SceneView;
import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

public class WorkshopApp extends Application {
    
    // Exercise 1: Declare fields, including UI components
    private ArcGISMap map;
    private ArcGISScene scene;
    private boolean threeD = false;
    private MapView mapView;
    private SceneView sceneView;
    private final ImageView imageView_2d = new ImageView(new Image(getClass().getResourceAsStream("/resources/two-d.png")));
    private final ImageView imageView_3d = new ImageView(new Image(getClass().getResourceAsStream("/resources/three-d.png")));
    private final Button button_toggle2d3d = new Button(null, imageView_3d);
    private final AnchorPane anchorPane = new AnchorPane();
    
    @Override
    public void start(Stage primaryStage) {
        // Exercise 1: Set the 2D/3D toggle button's action
        button_toggle2d3d.setOnAction((ActionEvent event) -> {
            button_toggle2d3d_onAction();
        });
        
        // Exercise 1: Set up the 2D map, since we will display that first
        map = new ArcGISMap();
        map.setBasemap(Basemap.createNationalGeographic());
        mapView = new MapView();
        mapView.setMap(map);
        
        // Exercise 1: Place the MapView and 2D/3D toggle button in the UI
        AnchorPane.setLeftAnchor(mapView, 0.0);
        AnchorPane.setRightAnchor(mapView, 0.0);
        AnchorPane.setTopAnchor(mapView, 0.0);
        AnchorPane.setBottomAnchor(mapView, 0.0);
        AnchorPane.setRightAnchor(button_toggle2d3d, 15.0);
        AnchorPane.setBottomAnchor(button_toggle2d3d, 15.0);
        anchorPane.getChildren().addAll(mapView, button_toggle2d3d);

        // Exercise 1: Finish displaying the UI
        // JavaFX Scene (unrelated to ArcGIS 3D scene)
        Scene javaFxScene = new Scene(anchorPane);
        primaryStage.setTitle("My first map application");
        primaryStage.setWidth(800);
        primaryStage.setHeight(600);
        primaryStage.setScene(javaFxScene);
        primaryStage.show();        
    }
    
    /**
     * Exercise 1: Toggle between 2D map and 3D scene
     */
    private void button_toggle2d3d_onAction() {
        threeD = !threeD;
        button_toggle2d3d.setGraphic(threeD ? imageView_2d : imageView_3d);

        if (threeD) {
            if (null == sceneView) {
                // Set up the 3D scene. This only happens the first time the user switches to 3D.
                scene = new ArcGISScene();
                scene.setBasemap(Basemap.createNationalGeographic());
                scene.getOperationalLayers().addAll(map.getOperationalLayers());
                sceneView = new SceneView();
                sceneView.setArcGISScene(scene);
                AnchorPane.setLeftAnchor(sceneView, 0.0);
                AnchorPane.setRightAnchor(sceneView, 0.0);
                AnchorPane.setTopAnchor(sceneView, 0.0);
                AnchorPane.setBottomAnchor(sceneView, 0.0);
            }
            anchorPane.getChildren().remove(mapView);
            anchorPane.getChildren().add(0, sceneView);
        } else {
            anchorPane.getChildren().remove(sceneView);
            anchorPane.getChildren().add(0, mapView);
        }
    }

    @Override
    public void stop() throws Exception {
        // Exercise 1: dispose the MapView and SceneView before exiting
        mapView.dispose();
        if (null != sceneView) {
            sceneView.dispose();
        }
        
        super.stop();
    }

    public static void main(String[] args) {
        launch(args);
    }
    
}
