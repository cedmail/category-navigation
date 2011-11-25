<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="propertyDefinition" type="org.jahia.services.content.nodetypes.ExtendedPropertyDefinition"--%>
<%--@elvariable id="type" type="org.jahia.services.content.nodetypes.ExtendedNodeType"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<jsp:useBean id="searchCategories" scope="session" class="java.util.LinkedHashMap"/>
<c:set var="category"
       value="${ui:getBindedComponent(currentNode, renderContext, 'j:bindedComponent').properties['associatedCategory'].node}"/>
<c:if test="${empty searchCategories or empty searchCategories[category.name]}">
    <jcr:sql
            sql="select * from [jnt:category] as cat where issamenode('${category.path}') or isdescendantnode(cat,'${category.path}')"
            var="categories"/>
    <c:set target="${searchCategories}" property="${category.name}" value=""/>
    <c:forEach items="${categories.nodes}" var="categ" varStatus="status">
        <c:choose>
            <c:when test="${status.first}">
                <c:set target="${searchCategories}" property="${category.name}" value="content.[j:defaultCategory]='${categ.identifier}'"/>
            </c:when>
            <c:otherwise>
                <c:set target="${searchCategories}" property="${category.name}"
                       value="${searchCategories[category.name]} OR content.[j:defaultCategory]='${categ.identifier}'"/>
            </c:otherwise>
        </c:choose>
    </c:forEach>
</c:if>
<query:definition var="listQuery"
                  statement="select content.* from [${currentNode.properties['applyOn'].string}] as content
             where isdescendantnode(content,'${renderContext.site.path}')
             and (${searchCategories[category.name]})
             order by content.[jcr:lastModified] desc" limit="10"/>
<c:set target="${moduleMap}" property="listQuery" value="${listQuery}"/>