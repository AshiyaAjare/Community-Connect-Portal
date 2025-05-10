// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from "@rails/ujs";
Rails.start();

import "@hotwired/turbo-rails"
// import "controllers"
import { Turbo } from "@hotwired/turbo-rails"
import "./application";
import "bootstrap";
import "bootstrap/dist/css/bootstrap.min.css";