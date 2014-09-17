package au.org.ala.images

import grails.converters.JSON
import grails.transaction.NotTransactional
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.elasticsearch.action.delete.DeleteResponse
import org.elasticsearch.action.index.IndexResponse
import org.elasticsearch.action.search.SearchResponse
import org.elasticsearch.action.search.SearchType
import org.elasticsearch.client.Client
import org.elasticsearch.common.settings.ImmutableSettings

import javax.annotation.PreDestroy

import static org.elasticsearch.node.NodeBuilder.nodeBuilder
import javax.annotation.PostConstruct
import org.elasticsearch.node.Node

class ElasticSearchService {

    def logService
    def grailsApplication

    private Node node
    private Client client


    @NotTransactional
    @PostConstruct
    def initialize() {
        logService.log("ElasticSearch service starting...")
        ImmutableSettings.Builder settings = ImmutableSettings.settingsBuilder();
        settings.put("path.home", grailsApplication.config.elasticsearch.location);
        node = nodeBuilder().local(true).settings(settings).node();
        client = node.client();
        client.admin().cluster().prepareHealth().setWaitForYellowStatus().execute().actionGet();
        logService.log("ElasticSearch service initialisation complete.")
    }

    @PreDestroy
    def destroy() {
        if (node) {
            node.close();
        }
    }

    public deleteIndex() {
        try {
            def ct = new CodeTimer("Index deletion")
            node.client().admin().indices().prepareDelete("images").execute().get()
            ct.stop(true)
        } catch (Exception) {
            // failed to delete index - maybe because it didn't exist?
        }
    }

    def indexImage(Image image) {
        def ct = new CodeTimer("Index Image ${image.id}")
        // only add the fields that are searchable. They are marked with an annotation
        def fields = Image.class.declaredFields
        def data = [:]
        fields.each { field ->
            if (field.isAnnotationPresent(SearchableProperty)) {
                data[field.name] = image."${field.name}"
            }
        }

        def md = ImageMetaDataItem.findAllByImage(image)
        data.metadata = [:]
        md.each {
            data.metadata[it.name] = it.value
        }

        def json = (data as JSON).toString()

        IndexResponse response = client.prepareIndex("images", "image", image.id.toString()).setSource(json).execute().actionGet();
        ct.stop(true)
    }

    def deleteImage(Image image) {
        if (image) {
            DeleteResponse response = client.prepareDelete("images", "image", image.id.toString()).execute().actionGet();
        }
    }

    public QueryResults<Image> search(Map query, GrailsParameterMap params) {

        Map qmap = null
        Map fmap = null
        if (query.query) {
            qmap = query.query
        } else {
            if (query.filter) {
                fmap = query.filter
            } else {
                qmap = query
            }
        }

        def b = client.prepareSearch("images").setSearchType(SearchType.QUERY_THEN_FETCH)
        if (qmap) {
            b.setQuery(qmap)
        }

        if (fmap) {
            b.setPostFilter(fmap)
        }

        if (params.offset) {
            b.setFrom(params.int("offset"))
        }

        if (params.max) {
            b.setSize(params.int("max"))
        }

        def ct = new CodeTimer("Index search")
        SearchResponse searchResponse = b.execute().actionGet();
        ct.stop(true)

        ct = new CodeTimer("Object retrieval")
        def list = []
        if (searchResponse.hits) {
            searchResponse.hits.each { hit ->
                list << Image.get(hit.id.toLong())
            }
        }
        ct.stop(true)

        return new QueryResults<Image>(list: list, totalCount: searchResponse?.hits?.totalHits ?: 0)
    }

    def ping() {
        logService.log("ElasticSearch Service is ${node ? '' : 'NOT' } alive.")
    }
}
