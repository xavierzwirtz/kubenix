# This file was generated with kubenix k8s generator, do not edit
{ lib, options, config, ... }:

with lib;

let
  getDefaults = resource: group: version: kind:
    catAttrs "default" (filter (default:
      (default.resource == null || default.resource == resource)
      && (default.group == null || default.group == group)
      && (default.version == null || default.version == version)
      && (default.kind == null || default.kind == kind)) config.defaults);

  types = lib.types // rec {
    str = mkOptionType {
      name = "str";
      description = "string";
      check = isString;
      merge = mergeEqualOption;
    };

    # Either value of type `finalType` or `coercedType`, the latter is
    # converted to `finalType` using `coerceFunc`.
    coercedTo = coercedType: coerceFunc: finalType:
      mkOptionType rec {
        name = "coercedTo";
        description = "${finalType.description} or ${coercedType.description}";
        check = x: finalType.check x || coercedType.check x;
        merge = loc: defs:
          let
            coerceVal = val:
              if finalType.check val then
                val
              else
                let coerced = coerceFunc val; in assert finalType.check coerced; coerced;

          in finalType.merge loc (map (def: def // { value = coerceVal def.value; }) defs);
        getSubOptions = finalType.getSubOptions;
        getSubModules = finalType.getSubModules;
        substSubModules = m: coercedTo coercedType coerceFunc (finalType.substSubModules m);
        typeMerge = t1: t2: null;
        functor = (defaultFunctor name) // { wrapped = finalType; };
      };
  };

  mkOptionDefault = mkOverride 1001;

  mergeValuesByKey = mergeKey: values:
    listToAttrs (map (value:
      nameValuePair (if isAttrs value.${mergeKey} then
        toString value.${mergeKey}.content
      else
        (toString value.${mergeKey})) value) values);

  submoduleOf = ref:
    types.submodule ({ name, ... }: {
      options = definitions."${ref}".options or { };
      config = definitions."${ref}".config or { };
    });

  submoduleWithMergeOf = ref: mergeKey:
    types.submodule ({ name, ... }:
      let
        convertName = name:
          if definitions."${ref}".options.${mergeKey}.type == types.int then toInt name else name;
      in {
        options = definitions."${ref}".options;
        config = definitions."${ref}".config // {
          ${mergeKey} = mkOverride 1002 (convertName name);
        };
      });

  submoduleForDefinition = ref: resource: kind: group: version:
    let apiVersion = if group == "core" then version else "${group}/${version}";
    in types.submodule ({ name, ... }: {
      imports = getDefaults resource group version kind;
      options = definitions."${ref}".options;
      config = mkMerge [
        definitions."${ref}".config
        {
          kind = mkOptionDefault kind;
          apiVersion = mkOptionDefault apiVersion;

          # metdata.name cannot use option default, due deep config
          metadata.name = mkOptionDefault name;
        }
      ];
    });

  coerceAttrsOfSubmodulesToListByKey = ref: mergeKey:
    (types.coercedTo (types.listOf (submoduleOf ref)) (mergeValuesByKey mergeKey)
      (types.attrsOf (submoduleWithMergeOf ref mergeKey)));

  definitions = {
    "io.k8s.apimachinery.pkg.api.resource.Quantity" = {

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.APIGroup" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "name is the name of the group.";
          type = types.str;
        };
        "preferredVersion" = mkOption {
          description =
            "preferredVersion is the version preferred by the API server, which probably is the storage version.";
          type = (types.nullOr
            (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.GroupVersionForDiscovery"));
        };
        "serverAddressByClientCIDRs" = mkOption {
          description =
            "a map of client CIDR to server address that is serving this group. This is to help clients reach servers in the most network-efficient way possible. Clients can use the appropriate server address as per the CIDR that they match. In case of multiple matches, clients should use the longest matching CIDR. The server returns only those CIDRs that it thinks that the client can match. For example: the master will return an internal IP CIDR only, if the client reaches the server using an internal IP. Server looks at X-Forwarded-For header or X-Real-Ip header or request.RemoteAddr (in that order) to get the client IP.";
          type = (types.listOf
            (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ServerAddressByClientCIDR"));
        };
        "versions" = mkOption {
          description = "versions are the versions supported in this group.";
          type = (types.listOf
            (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.GroupVersionForDiscovery"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "preferredVersion" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.APIGroupList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "groups" = mkOption {
          description = "groups is a list of APIGroup.";
          type = (types.listOf (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.APIGroup"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.APIResource" = {

      options = {
        "categories" = mkOption {
          description =
            "categories is a list of the grouped resources this resource belongs to (e.g. 'all')";
          type = (types.nullOr (types.listOf types.str));
        };
        "kind" = mkOption {
          description =
            "kind is the kind for the resource (e.g. 'Foo' is the kind for a resource 'foo')";
          type = types.str;
        };
        "name" = mkOption {
          description = "name is the plural name of the resource.";
          type = types.str;
        };
        "namespaced" = mkOption {
          description = "namespaced indicates if a resource is namespaced or not.";
          type = types.bool;
        };
        "shortNames" = mkOption {
          description = "shortNames is a list of suggested short names of the resource.";
          type = (types.nullOr (types.listOf types.str));
        };
        "singularName" = mkOption {
          description =
            "singularName is the singular name of the resource.  This allows clients to handle plural and singular opaquely. The singularName is more correct for reporting status on a single item and both singular and plural are allowed from the kubectl CLI interface.";
          type = types.str;
        };
        "verbs" = mkOption {
          description =
            "verbs is a list of supported kube verbs (this includes get, list, watch, create, update, patch, delete, deletecollection, and proxy)";
          type = (types.listOf types.str);
        };
      };

      config = {
        "categories" = mkOverride 1002 null;
        "shortNames" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.APIResourceList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "groupVersion" = mkOption {
          description = "groupVersion is the group and version this APIResourceList is for.";
          type = types.str;
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "resources" = mkOption {
          description = "resources contains the name of the resources and if they are namespaced.";
          type = (types.listOf (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.APIResource"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.APIVersions" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "serverAddressByClientCIDRs" = mkOption {
          description =
            "a map of client CIDR to server address that is serving this group. This is to help clients reach servers in the most network-efficient way possible. Clients can use the appropriate server address as per the CIDR that they match. In case of multiple matches, clients should use the longest matching CIDR. The server returns only those CIDRs that it thinks that the client can match. For example: the master will return an internal IP CIDR only, if the client reaches the server using an internal IP. Server looks at X-Forwarded-For header or X-Real-Ip header or request.RemoteAddr (in that order) to get the client IP.";
          type = (types.listOf
            (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ServerAddressByClientCIDR"));
        };
        "versions" = mkOption {
          description = "versions are the api versions that are available.";
          type = (types.listOf types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.DeleteOptions" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "gracePeriodSeconds" = mkOption {
          description =
            "The duration in seconds before the object should be deleted. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period for the specified type will be used. Defaults to a per object value if not specified. zero means delete immediately.";
          type = (types.nullOr types.int);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "orphanDependents" = mkOption {
          description = ''
            Deprecated: please use the PropagationPolicy, this field will be deprecated in 1.7. Should the dependent objects be orphaned. If true/false, the "orphan" finalizer will be added to/removed from the object's finalizers list. Either this field or PropagationPolicy may be set, but not both.'';
          type = (types.nullOr types.bool);
        };
        "preconditions" = mkOption {
          description =
            "Must be fulfilled before a deletion is carried out. If not possible, a 409 Conflict status will be returned.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.Preconditions"));
        };
        "propagationPolicy" = mkOption {
          description =
            "Whether and how garbage collection will be performed. Either this field or OrphanDependents may be set, but not both. The default policy is decided by the existing finalizer set in the metadata.finalizers and the resource-specific default policy.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "gracePeriodSeconds" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "orphanDependents" = mkOverride 1002 null;
        "preconditions" = mkOverride 1002 null;
        "propagationPolicy" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.GroupVersionForDiscovery" = {

      options = {
        "groupVersion" = mkOption {
          description =
            ''groupVersion specifies the API group and version in the form "group/version"'';
          type = types.str;
        };
        "version" = mkOption {
          description = ''
            version specifies the version in the form of "version". This is to save the clients the trouble of splitting the GroupVersion.'';
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.Initializer" = {

      options = {
        "name" = mkOption {
          description = "name of the process that is responsible for initializing this object.";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.Initializers" = {

      options = {
        "pending" = mkOption {
          description =
            "Pending is a list of initializers that must execute in order before this object is visible. When the last pending initializer is removed, and no failing result is set, the initializers struct will be set to nil and the object is considered as initialized and visible to all clients.";
          type = (types.listOf (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.Initializer"));
        };
        "result" = mkOption {
          description =
            "If result is set with the Failure field, the object will be persisted to storage and then deleted, ensuring that other clients can observe the deletion.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.Status"));
        };
      };

      config = { "result" = mkOverride 1002 null; };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description =
            "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelectorRequirement")));
        };
        "matchLabels" = mkOption {
          description = ''
            matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.'';
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelectorRequirement" = {

      options = {
        "key" = mkOption {
          description = "key is the label key that the selector applies to.";
          type = types.str;
        };
        "operator" = mkOption {
          description =
            "operator represents a key's relationship to a set of values. Valid operators ard In, NotIn, Exists and DoesNotExist.";
          type = types.str;
        };
        "values" = mkOption {
          description =
            "values is an array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. This array is replaced during a strategic merge patch.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = { "values" = mkOverride 1002 null; };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta" = {

      options = {
        "resourceVersion" = mkOption {
          description =
            "String that identifies the server's internal version of this object that can be used by clients to determine when objects have changed. Value must be treated as opaque by clients and passed unmodified back to the server. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency";
          type = (types.nullOr types.str);
        };
        "selfLink" = mkOption {
          description =
            "SelfLink is a URL representing this object. Populated by the system. Read-only.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "resourceVersion" = mkOverride 1002 null;
        "selfLink" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta" = {

      options = {
        "annotations" = mkOption {
          description =
            "Annotations is an unstructured key value map stored with a resource that may be set by external tools to store and retrieve arbitrary metadata. They are not queryable and should be preserved when modifying objects. More info: http://kubernetes.io/docs/user-guide/annotations";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "clusterName" = mkOption {
          description =
            "The name of the cluster which the object belongs to. This is used to distinguish resources with same name and namespace in different clusters. This field is not set anywhere right now and apiserver is going to ignore it if set in create or update request.";
          type = (types.nullOr types.str);
        };
        "creationTimestamp" = mkOption {
          description = ''
            CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC.

            Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata'';
          type = (types.nullOr types.str);
        };
        "deletionGracePeriodSeconds" = mkOption {
          description =
            "Number of seconds allowed for this object to gracefully terminate before it will be removed from the system. Only set when deletionTimestamp is also set. May only be shortened. Read-only.";
          type = (types.nullOr types.int);
        };
        "deletionTimestamp" = mkOption {
          description = ''
            DeletionTimestamp is RFC 3339 date and time at which this resource will be deleted. This field is set by the server when a graceful deletion is requested by the user, and is not directly settable by a client. The resource is expected to be deleted (no longer visible from resource lists, and not reachable by name) after the time in this field. Once set, this value may not be unset or be set further into the future, although it may be shortened or the resource may be deleted prior to this time. For example, a user may request that a pod is deleted in 30 seconds. The Kubelet will react by sending a graceful termination signal to the containers in the pod. After that 30 seconds, the Kubelet will send a hard termination signal (SIGKILL) to the container and after cleanup, remove the pod from the API. In the presence of network partitions, this object may still exist after this timestamp, until an administrator or automated process can determine the resource is fully terminated. If not set, graceful deletion of the object has not been requested.

            Populated by the system when a graceful deletion is requested. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata'';
          type = (types.nullOr types.str);
        };
        "finalizers" = mkOption {
          description =
            "Must be empty before the object is deleted from the registry. Each entry is an identifier for the responsible component that will remove the entry from the list. If the deletionTimestamp of the object is non-nil, entries in this list can only be removed.";
          type = (types.nullOr (types.listOf types.str));
        };
        "generateName" = mkOption {
          description = ''
            GenerateName is an optional prefix, used by the server, to generate a unique name ONLY IF the Name field has not been provided. If this field is used, the name returned to the client will be different than the name passed. This value will also be combined with a unique suffix. The provided value has the same validation rules as the Name field, and may be truncated by the length of the suffix required to make the value unique on the server.

            If this field is specified and the generated name exists, the server will NOT return a 409 - instead, it will either return 201 Created or 500 with Reason ServerTimeout indicating a unique name could not be found in the time allotted, and the client should retry (optionally after the time indicated in the Retry-After header).

            Applied only if Name is not specified. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#idempotency'';
          type = (types.nullOr types.str);
        };
        "generation" = mkOption {
          description =
            "A sequence number representing a specific generation of the desired state. Populated by the system. Read-only.";
          type = (types.nullOr types.int);
        };
        "initializers" = mkOption {
          description = ''
            An initializer is a controller which enforces some system invariant at object creation time. This field is a list of initializers that have not yet acted on this object. If nil or empty, this object has been completely initialized. Otherwise, the object is considered uninitialized and is hidden (in list/watch and get calls) from clients that haven't explicitly asked to observe uninitialized objects.

            When an object is created, the system will populate this list with the current set of initializers. Only privileged users may set or modify this list. Once it is empty, it may not be modified further by any user.'';
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.Initializers"));
        };
        "labels" = mkOption {
          description =
            "Map of string keys and values that can be used to organize and categorize (scope and select) objects. May match selectors of replication controllers and services. More info: http://kubernetes.io/docs/user-guide/labels";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description =
            "Name must be unique within a namespace. Is required when creating resources, although some resources may allow a client to request the generation of an appropriate name automatically. Name is primarily intended for creation idempotence and configuration definition. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/identifiers#names";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = ''
            Namespace defines the space within each name must be unique. An empty namespace is equivalent to the "default" namespace, but "default" is the canonical representation. Not all objects are required to be scoped to a namespace - the value of this field for those objects will be empty.

            Must be a DNS_LABEL. Cannot be updated. More info: http://kubernetes.io/docs/user-guide/namespaces'';
          type = (types.nullOr types.str);
        };
        "ownerReferences" = mkOption {
          description =
            "List of objects depended by this object. If ALL objects in the list have been deleted, this object will be garbage collected. If this object is managed by a controller, then an entry in this list will point to this controller, with the controller field set to true. There cannot be more than one managing controller.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.apimachinery.pkg.apis.meta.v1.OwnerReference" "uid"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "resourceVersion" = mkOption {
          description = ''
            An opaque value that represents the internal version of this object that can be used by clients to determine when objects have changed. May be used for optimistic concurrency, change detection, and the watch operation on a resource or set of resources. Clients must treat these values as opaque and passed unmodified back to the server. They may only be valid for a particular resource or set of resources.

            Populated by the system. Read-only. Value must be treated as opaque by clients and . More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency'';
          type = (types.nullOr types.str);
        };
        "selfLink" = mkOption {
          description =
            "SelfLink is a URL representing this object. Populated by the system. Read-only.";
          type = (types.nullOr types.str);
        };
        "uid" = mkOption {
          description = ''
            UID is the unique in time and space value for this object. It is typically generated by the server on successful creation of a resource and is not allowed to change on PUT operations.

            Populated by the system. Read-only. More info: http://kubernetes.io/docs/user-guide/identifiers#uids'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "clusterName" = mkOverride 1002 null;
        "creationTimestamp" = mkOverride 1002 null;
        "deletionGracePeriodSeconds" = mkOverride 1002 null;
        "deletionTimestamp" = mkOverride 1002 null;
        "finalizers" = mkOverride 1002 null;
        "generateName" = mkOverride 1002 null;
        "generation" = mkOverride 1002 null;
        "initializers" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "ownerReferences" = mkOverride 1002 null;
        "resourceVersion" = mkOverride 1002 null;
        "selfLink" = mkOverride 1002 null;
        "uid" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.OwnerReference" = {

      options = {
        "apiVersion" = mkOption {
          description = "API version of the referent.";
          type = types.str;
        };
        "blockOwnerDeletion" = mkOption {
          description = ''
            If true, AND if the owner has the "foregroundDeletion" finalizer, then the owner cannot be deleted from the key-value store until this reference is removed. Defaults to false. To set this field, a user needs "delete" permission of the owner, otherwise 422 (Unprocessable Entity) will be returned.'';
          type = (types.nullOr types.bool);
        };
        "controller" = mkOption {
          description = "If true, this reference points to the managing controller.";
          type = (types.nullOr types.bool);
        };
        "kind" = mkOption {
          description =
            "Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = types.str;
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#names";
          type = types.str;
        };
        "uid" = mkOption {
          description =
            "UID of the referent. More info: http://kubernetes.io/docs/user-guide/identifiers#uids";
          type = types.str;
        };
      };

      config = {
        "blockOwnerDeletion" = mkOverride 1002 null;
        "controller" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.Patch" = {

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.Preconditions" = {

      options = {
        "uid" = mkOption {
          description = "Specifies the target UID.";
          type = (types.nullOr types.str);
        };
      };

      config = { "uid" = mkOverride 1002 null; };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.ServerAddressByClientCIDR" = {

      options = {
        "clientCIDR" = mkOption {
          description =
            "The CIDR with which clients can match their IP to figure out the server address that they should use.";
          type = types.str;
        };
        "serverAddress" = mkOption {
          description =
            "Address of this server, suitable for a client that matches the above CIDR. This can be a hostname, hostname:port, IP or IP:port.";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.Status" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "code" = mkOption {
          description = "Suggested HTTP return code for this status, 0 if not set.";
          type = (types.nullOr types.int);
        };
        "details" = mkOption {
          description =
            "Extended data associated with the reason.  Each reason may define its own extended details. This field is optional and the data returned is not guaranteed to conform to any schema except that defined by the reason type.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.StatusDetails"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "A human-readable description of the status of this operation.";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
        "reason" = mkOption {
          description = ''
            A machine-readable description of why this operation is in the "Failure" status. If this value is empty there is no information available. A Reason clarifies an HTTP status code but does not override it.'';
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = ''
            Status of the operation. One of: "Success" or "Failure". More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "code" = mkOverride 1002 null;
        "details" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.StatusCause" = {

      options = {
        "field" = mkOption {
          description = ''
            The field of the resource that has caused this error, as named by its JSON serialization. May include dot and postfix notation for nested attributes. Arrays are zero-indexed.  Fields may appear more than once in an array of causes due to fields having multiple errors. Optional.

            Examples:
              "name" - the field "name" on the current resource
              "items[0].name" - the field "name" on the first array entry in "items"'';
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description =
            "A human-readable description of the cause of the error.  This field may be presented as-is to a reader.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description =
            "A machine-readable description of the cause of the error. If this value is empty there is no information available.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "field" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.StatusDetails" = {

      options = {
        "causes" = mkOption {
          description =
            "The Causes array includes more details associated with the StatusReason failure. Not all StatusReasons may provide detailed causes.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.StatusCause")));
        };
        "group" = mkOption {
          description =
            "The group attribute of the resource associated with the status StatusReason.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "The kind attribute of the resource associated with the status StatusReason. On some operations may differ from the requested resource Kind. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description =
            "The name attribute of the resource associated with the status StatusReason (when there is a single name which can be described).";
          type = (types.nullOr types.str);
        };
        "retryAfterSeconds" = mkOption {
          description = "If specified, the time in seconds before the operation should be retried.";
          type = (types.nullOr types.int);
        };
        "uid" = mkOption {
          description =
            "UID of the resource. (when there is a single resource which can be described). More info: http://kubernetes.io/docs/user-guide/identifiers#uids";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "causes" = mkOverride 1002 null;
        "group" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "retryAfterSeconds" = mkOverride 1002 null;
        "uid" = mkOverride 1002 null;
      };

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.Time" = {

    };
    "io.k8s.apimachinery.pkg.apis.meta.v1.WatchEvent" = {

      options = {
        "object" = mkOption {
          description = ''
            Object is:
             * If Type is Added or Modified: the new state of the object.
             * If Type is Deleted: the state of the object immediately before deletion.
             * If Type is Error: *Status is recommended; other types may make sense
               depending on context.'';
          type = (submoduleOf "io.k8s.apimachinery.pkg.runtime.RawExtension");
        };
        "type" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.apimachinery.pkg.runtime.RawExtension" = {

      options = {
        "Raw" = mkOption {
          description = "Raw is the underlying serialization of this object.";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.apimachinery.pkg.util.intstr.IntOrString" = {

    };
    "io.k8s.apimachinery.pkg.version.Info" = {

      options = {
        "buildDate" = mkOption {
          description = "";
          type = types.str;
        };
        "compiler" = mkOption {
          description = "";
          type = types.str;
        };
        "gitCommit" = mkOption {
          description = "";
          type = types.str;
        };
        "gitTreeState" = mkOption {
          description = "";
          type = types.str;
        };
        "gitVersion" = mkOption {
          description = "";
          type = types.str;
        };
        "goVersion" = mkOption {
          description = "";
          type = types.str;
        };
        "major" = mkOption {
          description = "";
          type = types.str;
        };
        "minor" = mkOption {
          description = "";
          type = types.str;
        };
        "platform" = mkOption {
          description = "";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIService" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec contains information for locating and communicating with a server";
          type = (types.nullOr
            (submoduleOf "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceSpec"));
        };
        "status" = mkOption {
          description = "Status contains derived information about an API server";
          type = (types.nullOr (submoduleOf
            "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceCondition" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "Last time the condition transitioned from one status to another.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "Human-readable message indicating details about last transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "Unique, one-word, CamelCase reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status is the status of the condition. Can be True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type is the type of the condition.";
          type = types.str;
        };
      };

      config = {
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "";
          type = (types.listOf
            (submoduleOf "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIService"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceSpec" = {

      options = {
        "caBundle" = mkOption {
          description =
            "CABundle is a PEM encoded CA bundle which will be used to validate an API server's serving certificate.";
          type = types.str;
        };
        "group" = mkOption {
          description = "Group is the API group name this server hosts";
          type = (types.nullOr types.str);
        };
        "groupPriorityMinimum" = mkOption {
          description =
            "GroupPriorityMininum is the priority this group should have at least. Higher priority means that the group is prefered by clients over lower priority ones. Note that other versions of this group might specify even higher GroupPriorityMininum values such that the whole group gets a higher priority. The primary sort is based on GroupPriorityMinimum, ordered highest number to lowest (20 before 10). The secondary sort is based on the alphabetical comparison of the name of the object.  (v1.bar before v1.foo) We'd recommend something like: *.k8s.io (except extensions) at 18000 and PaaSes (OpenShift, Deis) are recommended to be in the 2000s";
          type = types.int;
        };
        "insecureSkipTLSVerify" = mkOption {
          description =
            "InsecureSkipTLSVerify disables TLS certificate verification when communicating with this server. This is strongly discouraged.  You should use the CABundle instead.";
          type = (types.nullOr types.bool);
        };
        "service" = mkOption {
          description =
            "Service is a reference to the service for this API server.  It must communicate on port 443 If the Service is nil, that means the handling for the API groupversion is handled locally on this server. The call will simply delegate to the normal handler chain to be fulfilled.";
          type = (submoduleOf
            "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.ServiceReference");
        };
        "version" = mkOption {
          description = ''Version is the API version this server hosts.  For example, "v1"'';
          type = (types.nullOr types.str);
        };
        "versionPriority" = mkOption {
          description =
            "VersionPriority controls the ordering of this API version inside of its group.  Must be greater than zero. The primary sort is based on VersionPriority, ordered highest to lowest (20 before 10). The secondary sort is based on the alphabetical comparison of the name of the object.  (v1.bar before v1.foo) Since it's inside of a group, the number can be small, probably in the 10s.";
          type = types.int;
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "insecureSkipTLSVerify" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceStatus" = {

      options = {
        "conditions" = mkOption {
          description = "Current service state of apiService.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIServiceCondition" "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
      };

      config = { "conditions" = mkOverride 1002 null; };

    };
    "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.ServiceReference" = {

      options = {
        "name" = mkOption {
          description = "Name is the name of the service";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = "Namespace is the namespace of the service";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.AWSElasticBlockStoreVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore'';
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = ''
            The partition in the volume that you want to mount. If omitted, the default is to mount by volume name. Examples: For volume /dev/sda1, you specify the partition as "1". Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty).'';
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = ''
            Specify "true" to force and set the ReadOnly property in VolumeMounts to "true". If omitted, the default is "false". More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore'';
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description =
            "Unique ID of the persistent disk resource in AWS (Amazon EBS volume). More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Affinity" = {

      options = {
        "nodeAffinity" = mkOption {
          description = "Describes node affinity scheduling rules for the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeAffinity"));
        };
        "podAffinity" = mkOption {
          description =
            "Describes pod affinity scheduling rules (e.g. co-locate this pod in the same node, zone, etc. as some other pod(s)).";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodAffinity"));
        };
        "podAntiAffinity" = mkOption {
          description =
            "Describes pod anti-affinity scheduling rules (e.g. avoid putting this pod in the same node, zone, etc. as some other pod(s)).";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodAntiAffinity"));
        };
      };

      config = {
        "nodeAffinity" = mkOverride 1002 null;
        "podAffinity" = mkOverride 1002 null;
        "podAntiAffinity" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.AttachedVolume" = {

      options = {
        "devicePath" = mkOption {
          description =
            "DevicePath represents the device path where the volume should be available";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the attached volume";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.AzureDiskVolumeSource" = {

      options = {
        "cachingMode" = mkOption {
          description = "Host Caching mode: None, Read Only, Read Write.";
          type = (types.nullOr types.str);
        };
        "diskName" = mkOption {
          description = "The Name of the data disk in the blob storage";
          type = types.str;
        };
        "diskURI" = mkOption {
          description = "The URI the data disk in the blob storage";
          type = types.str;
        };
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Expected values Shared: mulitple blob disks per storage account  Dedicated: single blob disk per storage account  Managed: azure managed data disk (only in managed availability set). defaults to shared";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "cachingMode" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.AzureFileVolumeSource" = {

      options = {
        "readOnly" = mkOption {
          description =
            "Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "the name of secret that contains Azure Storage Account Name and Key";
          type = types.str;
        };
        "shareName" = mkOption {
          description = "Share Name";
          type = types.str;
        };
      };

      config = { "readOnly" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.Binding" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "target" = mkOption {
          description = "The target object that you want to bind to the standard object.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectReference");
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Capabilities" = {

      options = {
        "add" = mkOption {
          description = "Added capabilities";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "Removed capabilities";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.CephFSVolumeSource" = {

      options = {
        "monitors" = mkOption {
          description =
            "Required: Monitors is a collection of Ceph monitors More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it";
          type = (types.listOf types.str);
        };
        "path" = mkOption {
          description =
            "Optional: Used as the mounted root, rather than the full Ceph tree, default is /";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts. More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr types.bool);
        };
        "secretFile" = mkOption {
          description =
            "Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description =
            "Optional: SecretRef is reference to the authentication secret for User, default is empty. More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference"));
        };
        "user" = mkOption {
          description =
            "Optional: User is the rados user name, default is admin More info: https://releases.k8s.io/HEAD/examples/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretFile" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.CinderVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md'';
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts. More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description =
            "volume id used to identify the volume in cinder More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ComponentCondition" = {

      options = {
        "error" = mkOption {
          description =
            "Condition error code for a component. For example, a health check error code.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description =
            "Message about the condition for a component. For example, information about a health check.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = ''
            Status of the condition for a component. Valid values for "Healthy": "True", "False", or "Unknown".'';
          type = types.str;
        };
        "type" = mkOption {
          description = ''Type of condition for a component. Valid value: "Healthy"'';
          type = types.str;
        };
      };

      config = {
        "error" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ComponentStatus" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "conditions" = mkOption {
          description = "List of component conditions observed";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.ComponentCondition"
              "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ComponentStatusList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of ComponentStatus objects.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ComponentStatus"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ConfigMap" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "data" = mkOption {
          description =
            "Data contains the configuration data. Each key must consist of alphanumeric characters, '-', '_' or '.'.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "data" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ConfigMapEnvSource" = {

      options = {
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the ConfigMap must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ConfigMapKeySelector" = {

      options = {
        "key" = mkOption {
          description = "The key to select.";
          type = types.str;
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the ConfigMap or it's key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ConfigMapList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of ConfigMaps.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ConfigMap"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ConfigMapProjection" = {

      options = {
        "items" = mkOption {
          description =
            "If unspecified, each key-value pair in the Data field of the referenced ConfigMap will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the ConfigMap, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.KeyToPath")));
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the ConfigMap or it's keys must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ConfigMapVolumeSource" = {

      options = {
        "defaultMode" = mkOption {
          description =
            "Optional: mode bits to use on created files by default. Must be a value between 0 and 0777. Defaults to 0644. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description =
            "If unspecified, each key-value pair in the Data field of the referenced ConfigMap will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the ConfigMap, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.KeyToPath")));
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the ConfigMap or it's keys must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Container" = {

      options = {
        "args" = mkOption {
          description =
            "Arguments to the entrypoint. The docker image's CMD is used if this is not provided. Variable references $(VAR_NAME) are expanded using the container's environment. If a variable cannot be resolved, the reference in the input string will be unchanged. The $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME). Escaped references will never be expanded, regardless of whether the variable exists or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description =
            "Entrypoint array. Not executed within a shell. The docker image's ENTRYPOINT is used if this is not provided. Variable references $(VAR_NAME) are expanded using the container's environment. If a variable cannot be resolved, the reference in the input string will be unchanged. The $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME). Escaped references will never be expanded, regardless of whether the variable exists or not. Cannot be updated. More info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "List of environment variables to set in the container. Cannot be updated.";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.EnvVar" "name"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "envFrom" = mkOption {
          description =
            "List of sources to populate environment variables in the container. The keys defined within a source must be a C_IDENTIFIER. All invalid keys will be reported as an event when the container is starting. When a key exists in multiple sources, the value associated with the last source will take precedence. Values defined by an Env with a duplicate key will take precedence. Cannot be updated.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EnvFromSource")));
        };
        "image" = mkOption {
          description =
            "Docker image name. More info: https://kubernetes.io/docs/concepts/containers/images";
          type = types.str;
        };
        "imagePullPolicy" = mkOption {
          description =
            "Image pull policy. One of Always, Never, IfNotPresent. Defaults to Always if :latest tag is specified, or IfNotPresent otherwise. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description =
            "Actions that the management system should take in response to container lifecycle events. Cannot be updated.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Lifecycle"));
        };
        "livenessProbe" = mkOption {
          description =
            "Periodic probe of container liveness. Container will be restarted if the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Probe"));
        };
        "name" = mkOption {
          description =
            "Name of the container specified as a DNS_LABEL. Each container in a pod must have a unique name (DNS_LABEL). Cannot be updated.";
          type = types.str;
        };
        "ports" = mkOption {
          description = ''
            List of ports to expose from the container. Exposing a port here gives the system additional information about the network connections a container uses, but is primarily informational. Not specifying a port here DOES NOT prevent that port from being exposed. Any port which is listening on the default "0.0.0.0" address inside a container will be accessible from the network. Cannot be updated.'';
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.ContainerPort"
              "containerPort"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "readinessProbe" = mkOption {
          description =
            "Periodic probe of container service readiness. Container will be removed from service endpoints if the probe fails. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Probe"));
        };
        "resources" = mkOption {
          description =
            "Compute Resources required by this container. Cannot be updated. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceRequirements"));
        };
        "securityContext" = mkOption {
          description =
            "Security options the pod should run with. More info: https://kubernetes.io/docs/concepts/policy/security-context/ More info: https://git.k8s.io/community/contributors/design-proposals/security_context.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SecurityContext"));
        };
        "stdin" = mkOption {
          description =
            "Whether this container should allocate a buffer for stdin in the container runtime. If this is not set, reads from stdin in the container will always result in EOF. Default is false.";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description =
            "Whether the container runtime should close the stdin channel after it has been opened by a single attach. When stdin is true the stdin stream will remain open across multiple attach sessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the first client attaches to stdin, and then remains open and accepts data until the client disconnects, at which time stdin is closed and remains closed until the container is restarted. If this flag is false, a container processes that reads from stdin will never receive an EOF. Default is false";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description =
            "Optional: Path at which the file to which the container's termination message will be written is mounted into the container's filesystem. Message written is intended to be brief final status, such as an assertion failure message. Will be truncated by the node if greater than 4096 bytes. The total message length across all containers will be limited to 12kb. Defaults to /dev/termination-log. Cannot be updated.";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description =
            "Indicate how the termination message should be populated. File will use the contents of terminationMessagePath to populate the container status message on both success and failure. FallbackToLogsOnError will use the last chunk of container log output if the termination message file is empty and the container exited with an error. The log output is limited to 2048 bytes or 80 lines, whichever is smaller. Defaults to File. Cannot be updated.";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description =
            "Whether this container should allocate a TTY for itself, also requires 'stdin' to be true. Default is false.";
          type = (types.nullOr types.bool);
        };
        "volumeMounts" = mkOption {
          description = "Pod volumes to mount into the container's filesystem. Cannot be updated.";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.VolumeMount"
              "mountPath"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "workingDir" = mkOption {
          description =
            "Container's working directory. If not specified, the container runtime's default will be used, which might be configured in the container image. Cannot be updated.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerImage" = {

      options = {
        "names" = mkOption {
          description = ''
            Names by which this image is known. e.g. ["gcr.io/google_containers/hyperkube:v1.0.7", "dockerhub.io/google_containers/hyperkube:v1.0.7"]'';
          type = (types.listOf types.str);
        };
        "sizeBytes" = mkOption {
          description = "The size of the image in bytes.";
          type = (types.nullOr types.int);
        };
      };

      config = { "sizeBytes" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerPort" = {

      options = {
        "containerPort" = mkOption {
          description =
            "Number of port to expose on the pod's IP address. This must be a valid port number, 0 u003c x u003c 65536.";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "What host IP to bind the external port to.";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description =
            "Number of port to expose on the host. If specified, this must be a valid port number, 0 u003c x u003c 65536. If HostNetwork is specified, this must match ContainerPort. Most containers do not need this.";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description =
            "If specified, this must be an IANA_SVC_NAME and unique within the pod. Each named port in a pod must have a unique name. Name for the port that can be referred to by services.";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = ''Protocol for port. Must be UDP or TCP. Defaults to "TCP".'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerState" = {

      options = {
        "running" = mkOption {
          description = "Details about a running container";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerStateRunning"));
        };
        "terminated" = mkOption {
          description = "Details about a terminated container";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerStateTerminated"));
        };
        "waiting" = mkOption {
          description = "Details about a waiting container";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerStateWaiting"));
        };
      };

      config = {
        "running" = mkOverride 1002 null;
        "terminated" = mkOverride 1002 null;
        "waiting" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerStateRunning" = {

      options = {
        "startedAt" = mkOption {
          description = "Time at which the container was last (re-)started";
          type = (types.nullOr types.str);
        };
      };

      config = { "startedAt" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerStateTerminated" = {

      options = {
        "containerID" = mkOption {
          description = "Container's ID in the format 'docker://u003ccontainer_idu003e'";
          type = (types.nullOr types.str);
        };
        "exitCode" = mkOption {
          description = "Exit status from the last termination of the container";
          type = types.int;
        };
        "finishedAt" = mkOption {
          description = "Time at which the container last terminated";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "Message regarding the last termination of the container";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "(brief) reason from the last termination of the container";
          type = (types.nullOr types.str);
        };
        "signal" = mkOption {
          description = "Signal from the last termination of the container";
          type = (types.nullOr types.int);
        };
        "startedAt" = mkOption {
          description = "Time at which previous execution of the container started";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "containerID" = mkOverride 1002 null;
        "finishedAt" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
        "signal" = mkOverride 1002 null;
        "startedAt" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerStateWaiting" = {

      options = {
        "message" = mkOption {
          description = "Message regarding why the container is not yet running.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "(brief) reason the container is not yet running.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ContainerStatus" = {

      options = {
        "containerID" = mkOption {
          description = "Container's ID in the format 'docker://u003ccontainer_idu003e'.";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description =
            "The image the container is running. More info: https://kubernetes.io/docs/concepts/containers/images";
          type = types.str;
        };
        "imageID" = mkOption {
          description = "ImageID of the container's image.";
          type = types.str;
        };
        "lastState" = mkOption {
          description = "Details about the container's last termination condition.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerState"));
        };
        "name" = mkOption {
          description =
            "This must be a DNS_LABEL. Each container in a pod must have a unique name. Cannot be updated.";
          type = types.str;
        };
        "ready" = mkOption {
          description = "Specifies whether the container has passed its readiness probe.";
          type = types.bool;
        };
        "restartCount" = mkOption {
          description =
            "The number of times the container has been restarted, currently based on the number of dead containers that have not yet been removed. Note that this is calculated from dead containers. But those containers are subject to garbage collection. This value will get capped at 5 by GC.";
          type = types.int;
        };
        "state" = mkOption {
          description = "Details about the container's current condition.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerState"));
        };
      };

      config = {
        "containerID" = mkOverride 1002 null;
        "lastState" = mkOverride 1002 null;
        "state" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.DaemonEndpoint" = {

      options = {
        "Port" = mkOption {
          description = "Port number of the given endpoint.";
          type = types.int;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.DownwardAPIProjection" = {

      options = {
        "items" = mkOption {
          description = "Items is a list of DownwardAPIVolume file";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.DownwardAPIVolumeFile")));
        };
      };

      config = { "items" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.DownwardAPIVolumeFile" = {

      options = {
        "fieldRef" = mkOption {
          description =
            "Required: Selects a field of the pod: only annotations, labels, name and namespace are supported.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectFieldSelector"));
        };
        "mode" = mkOption {
          description =
            "Optional: mode bits to use on this file, must be a value between 0 and 0777. If not specified, the volume defaultMode will be used. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description =
            "Required: Path is  the relative path name of the file to be created. Must not be absolute or contain the '..' path. Must be utf-8 encoded. The first item of the relative path must not start with '..'";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description =
            "Selects a resource of the container: only resources limits and requests (limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceFieldSelector"));
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.DownwardAPIVolumeSource" = {

      options = {
        "defaultMode" = mkOption {
          description =
            "Optional: mode bits to use on created files by default. Must be a value between 0 and 0777. Defaults to 0644. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "Items is a list of downward API volume file";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.DownwardAPIVolumeFile")));
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EmptyDirVolumeSource" = {

      options = {
        "medium" = mkOption {
          description = ''
            What type of storage medium should back this directory. The default is "" which means to use the node's default medium. Must be an empty string (default) or Memory. More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir'';
          type = (types.nullOr types.str);
        };
        "sizeLimit" = mkOption {
          description =
            "Total amount of local storage required for this EmptyDir volume. The size limit is also applicable for memory medium. The maximum usage on memory medium EmptyDir would be the minimum value between the SizeLimit specified here and the sum of memory limits of all containers in a pod. The default is nil which means that the limit is undefined. More info: http://kubernetes.io/docs/user-guide/volumes#emptydir";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "medium" = mkOverride 1002 null;
        "sizeLimit" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EndpointAddress" = {

      options = {
        "hostname" = mkOption {
          description = "The Hostname of this endpoint";
          type = (types.nullOr types.str);
        };
        "ip" = mkOption {
          description =
            "The IP of this endpoint. May not be loopback (127.0.0.0/8), link-local (169.254.0.0/16), or link-local multicast ((224.0.0.0/24). IPv6 is also accepted but not fully supported on all platforms. Also, certain kubernetes components, like kube-proxy, are not IPv6 ready.";
          type = types.str;
        };
        "nodeName" = mkOption {
          description =
            "Optional: Node hosting this endpoint. This can be used to determine endpoints local to a node.";
          type = (types.nullOr types.str);
        };
        "targetRef" = mkOption {
          description = "Reference to object providing the endpoint.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectReference"));
        };
      };

      config = {
        "hostname" = mkOverride 1002 null;
        "nodeName" = mkOverride 1002 null;
        "targetRef" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EndpointPort" = {

      options = {
        "name" = mkOption {
          description =
            "The name of this port (corresponds to ServicePort.Name). Must be a DNS_LABEL. Optional only if one port is defined.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "The port number of the endpoint.";
          type = types.int;
        };
        "protocol" = mkOption {
          description = "The IP protocol for this port. Must be UDP or TCP. Default is TCP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EndpointSubset" = {

      options = {
        "addresses" = mkOption {
          description =
            "IP addresses which offer the related ports that are marked as ready. These endpoints should be considered safe for load balancers and clients to utilize.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EndpointAddress")));
        };
        "notReadyAddresses" = mkOption {
          description =
            "IP addresses which offer the related ports but are not currently marked as ready because they have not yet finished starting, have recently failed a readiness check, or have recently failed a liveness check.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EndpointAddress")));
        };
        "ports" = mkOption {
          description = "Port numbers available on the related IP addresses.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EndpointPort")));
        };
      };

      config = {
        "addresses" = mkOverride 1002 null;
        "notReadyAddresses" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Endpoints" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "subsets" = mkOption {
          description =
            "The set of all endpoints is the union of all subsets. Addresses are placed into subsets according to the IPs they share. A single address with multiple ports, some of which are ready and some of which are not (because they come from different containers) will result in the address being displayed in different subsets for the different ports. No address will appear in both Addresses and NotReadyAddresses in the same subset. Sets of addresses and ports that comprise a service.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EndpointSubset"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EndpointsList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of endpoints.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Endpoints"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EnvFromSource" = {

      options = {
        "configMapRef" = mkOption {
          description = "The ConfigMap to select from";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ConfigMapEnvSource"));
        };
        "prefix" = mkOption {
          description =
            "An optional identifer to prepend to each key in the ConfigMap. Must be a C_IDENTIFIER.";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "The Secret to select from";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SecretEnvSource"));
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EnvVar" = {

      options = {
        "name" = mkOption {
          description = "Name of the environment variable. Must be a C_IDENTIFIER.";
          type = types.str;
        };
        "value" = mkOption {
          description = ''
            Variable references $(VAR_NAME) are expanded using the previous defined environment variables in the container and any service environment variables. If a variable cannot be resolved, the reference in the input string will be unchanged. The $(VAR_NAME) syntax can be escaped with a double $$, ie: $$(VAR_NAME). Escaped references will never be expanded, regardless of whether the variable exists or not. Defaults to "".'';
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description =
            "Source for the environment variable's value. Cannot be used if value is not empty.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EnvVarSource"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EnvVarSource" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "Selects a key of a ConfigMap.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ConfigMapKeySelector"));
        };
        "fieldRef" = mkOption {
          description =
            "Selects a field of the pod: supports metadata.name, metadata.namespace, metadata.labels, metadata.annotations, spec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectFieldSelector"));
        };
        "resourceFieldRef" = mkOption {
          description =
            "Selects a resource of the container: only resources limits and requests (limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceFieldSelector"));
        };
        "secretKeyRef" = mkOption {
          description = "Selects a key of a secret in the pod's namespace";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SecretKeySelector"));
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Event" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "count" = mkOption {
          description = "The number of times this event has occurred.";
          type = (types.nullOr types.int);
        };
        "firstTimestamp" = mkOption {
          description =
            "The time at which the event was first recorded. (Time of server receipt is in TypeMeta.)";
          type = (types.nullOr types.str);
        };
        "involvedObject" = mkOption {
          description = "The object that this event is about.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectReference");
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "lastTimestamp" = mkOption {
          description = "The time at which the most recent occurrence of this event was recorded.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "A human-readable description of the status of this operation.";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta");
        };
        "reason" = mkOption {
          description =
            "This should be a short, machine understandable string that gives the reason for the transition into the object's current status.";
          type = (types.nullOr types.str);
        };
        "source" = mkOption {
          description =
            "The component reporting this event. Should be a short machine understandable string.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EventSource"));
        };
        "type" = mkOption {
          description =
            "Type of this event (Normal, Warning), new types could be added in the future";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "count" = mkOverride 1002 null;
        "firstTimestamp" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "lastTimestamp" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
        "source" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EventList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of events";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Event"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.EventSource" = {

      options = {
        "component" = mkOption {
          description = "Component from which the event is generated.";
          type = (types.nullOr types.str);
        };
        "host" = mkOption {
          description = "Node name on which the event is generated.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "component" = mkOverride 1002 null;
        "host" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ExecAction" = {

      options = {
        "command" = mkOption {
          description =
            "Command is the command line to execute inside the container, the working directory for the command  is root ('/') in the container's filesystem. The command is simply exec'd, it is not run inside a shell, so traditional shell instructions ('|', etc) won't work. To use a shell, you need to explicitly call out to that shell. Exit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = { "command" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.FCVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "Required: FC target lun number";
          type = types.int;
        };
        "readOnly" = mkOption {
          description =
            "Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "targetWWNs" = mkOption {
          description = "Required: FC target worldwide names (WWNs)";
          type = (types.listOf types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.FlexVolumeSource" = {

      options = {
        "driver" = mkOption {
          description = "Driver is the name of the driver to use for this volume.";
          type = types.str;
        };
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". The default filesystem depends on FlexVolume script.'';
          type = (types.nullOr types.str);
        };
        "options" = mkOption {
          description = "Optional: Extra command options if any.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "readOnly" = mkOption {
          description =
            "Optional: Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description =
            "Optional: SecretRef is reference to the secret object containing sensitive information to pass to the plugin scripts. This may be empty if no secret object is specified. If the secret object contains more than one secret, all secrets are passed to the plugin scripts.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference"));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.FlockerVolumeSource" = {

      options = {
        "datasetName" = mkOption {
          description =
            "Name of the dataset stored as metadata -u003e name on the dataset for Flocker should be considered as deprecated";
          type = (types.nullOr types.str);
        };
        "datasetUUID" = mkOption {
          description = "UUID of the dataset. This is unique identifier of a Flocker dataset";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "datasetName" = mkOverride 1002 null;
        "datasetUUID" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.GCEPersistentDiskVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk'';
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = ''
            The partition in the volume that you want to mount. If omitted, the default is to mount by volume name. Examples: For volume /dev/sda1, you specify the partition as "1". Similarly, the volume partition for /dev/sda is "0" (or you can leave the property empty). More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk'';
          type = (types.nullOr types.int);
        };
        "pdName" = mkOption {
          description =
            "Unique name of the PD resource in GCE. Used to identify the disk in GCE. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = types.str;
        };
        "readOnly" = mkOption {
          description =
            "ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.GitRepoVolumeSource" = {

      options = {
        "directory" = mkOption {
          description =
            "Target directory name. Must not contain or start with '..'.  If '.' is supplied, the volume directory will be the git repository.  Otherwise, if specified, the volume will contain the git repository in the subdirectory with the given name.";
          type = (types.nullOr types.str);
        };
        "repository" = mkOption {
          description = "Repository URL";
          type = types.str;
        };
        "revision" = mkOption {
          description = "Commit hash for the specified revision.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "directory" = mkOverride 1002 null;
        "revision" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.GlusterfsVolumeSource" = {

      options = {
        "endpoints" = mkOption {
          description =
            "EndpointsName is the endpoint name that details Glusterfs topology. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod";
          type = types.str;
        };
        "path" = mkOption {
          description =
            "Path is the Glusterfs volume path. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod";
          type = types.str;
        };
        "readOnly" = mkOption {
          description =
            "ReadOnly here will force the Glusterfs volume to be mounted with read-only permissions. Defaults to false. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md#create-a-pod";
          type = (types.nullOr types.bool);
        };
      };

      config = { "readOnly" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.HTTPGetAction" = {

      options = {
        "host" = mkOption {
          description = ''
            Host name to connect to, defaults to the pod IP. You probably want to set "Host" in httpHeaders instead.'';
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.HTTPHeader")));
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description =
            "Name or number of the port to access on the container. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host. Defaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.HTTPHeader" = {

      options = {
        "name" = mkOption {
          description = "The header field name";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.Handler" = {

      options = {
        "exec" = mkOption {
          description =
            "One and only one of the following should be specified. Exec specifies the action to take.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ExecAction"));
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies the http request to perform.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.HTTPGetAction"));
        };
        "tcpSocket" = mkOption {
          description =
            "TCPSocket specifies an action involving a TCP port. TCP hooks not yet supported";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.TCPSocketAction"));
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.HostAlias" = {

      options = {
        "hostnames" = mkOption {
          description = "Hostnames for the above IP address.";
          type = (types.nullOr (types.listOf types.str));
        };
        "ip" = mkOption {
          description = "IP address of the host file entry.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostnames" = mkOverride 1002 null;
        "ip" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.HostPathVolumeSource" = {

      options = {
        "path" = mkOption {
          description =
            "Path of the directory on the host. More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.ISCSIVolumeSource" = {

      options = {
        "chapAuthDiscovery" = mkOption {
          description = "whether support iSCSI Discovery CHAP authentication";
          type = (types.nullOr types.bool);
        };
        "chapAuthSession" = mkOption {
          description = "whether support iSCSI Session CHAP authentication";
          type = (types.nullOr types.bool);
        };
        "fsType" = mkOption {
          description = ''
            Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi'';
          type = (types.nullOr types.str);
        };
        "iqn" = mkOption {
          description = "Target iSCSI Qualified Name.";
          type = types.str;
        };
        "iscsiInterface" = mkOption {
          description =
            "Optional: Defaults to 'default' (tcp). iSCSI interface name that uses an iSCSI transport.";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "iSCSI target lun number.";
          type = types.int;
        };
        "portals" = mkOption {
          description =
            "iSCSI target portal List. The portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260).";
          type = (types.nullOr (types.listOf types.str));
        };
        "readOnly" = mkOption {
          description =
            "ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "CHAP secret for iSCSI target and initiator authentication";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference"));
        };
        "targetPortal" = mkOption {
          description =
            "iSCSI target portal. The portal is either an IP or ip_addr:port if the port is other than default (typically TCP ports 860 and 3260).";
          type = types.str;
        };
      };

      config = {
        "chapAuthDiscovery" = mkOverride 1002 null;
        "chapAuthSession" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "iscsiInterface" = mkOverride 1002 null;
        "portals" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.KeyToPath" = {

      options = {
        "key" = mkOption {
          description = "The key to project.";
          type = types.str;
        };
        "mode" = mkOption {
          description =
            "Optional: mode bits to use on this file, must be a value between 0 and 0777. If not specified, the volume defaultMode will be used. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description =
            "The relative path of the file to map the key to. May not be an absolute path. May not contain the path element '..'. May not start with the string '..'.";
          type = types.str;
        };
      };

      config = { "mode" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.Lifecycle" = {

      options = {
        "postStart" = mkOption {
          description =
            "PostStart is called immediately after a container is created. If the handler fails, the container is terminated and restarted according to its restart policy. Other management of the container blocks until the hook completes. More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Handler"));
        };
        "preStop" = mkOption {
          description =
            "PreStop is called immediately before a container is terminated. The container is terminated after the handler completes. The reason for termination is passed to the handler. Regardless of the outcome of the handler, the container is eventually terminated. Other management of the container blocks until the hook completes. More info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Handler"));
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.LimitRange" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the limits enforced. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LimitRangeSpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.LimitRangeItem" = {

      options = {
        "default" = mkOption {
          description =
            "Default resource requirement limit value by resource name if resource limit is omitted.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "defaultRequest" = mkOption {
          description =
            "DefaultRequest is the default resource requirement request value by resource name if resource request is omitted.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "max" = mkOption {
          description = "Max usage constraints on this kind by resource name.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "maxLimitRequestRatio" = mkOption {
          description =
            "MaxLimitRequestRatio if specified, the named resource must have a request and limit that are both non-zero where limit divided by request is less than or equal to the enumerated value; this represents the max burst for the named resource.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "min" = mkOption {
          description = "Min usage constraints on this kind by resource name.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "type" = mkOption {
          description = "Type of resource that this limit applies to.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "default" = mkOverride 1002 null;
        "defaultRequest" = mkOverride 1002 null;
        "max" = mkOverride 1002 null;
        "maxLimitRequestRatio" = mkOverride 1002 null;
        "min" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.LimitRangeList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "Items is a list of LimitRange objects. More info: https://git.k8s.io/community/contributors/design-proposals/admission_control_limit_range.md";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LimitRange"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.LimitRangeSpec" = {

      options = {
        "limits" = mkOption {
          description = "Limits is the list of LimitRangeItem objects that are enforced.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LimitRangeItem"));
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.LoadBalancerIngress" = {

      options = {
        "hostname" = mkOption {
          description =
            "Hostname is set for load-balancer ingress points that are DNS based (typically AWS load-balancers)";
          type = (types.nullOr types.str);
        };
        "ip" = mkOption {
          description =
            "IP is set for load-balancer ingress points that are IP based (typically GCE or OpenStack load-balancers)";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostname" = mkOverride 1002 null;
        "ip" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.LoadBalancerStatus" = {

      options = {
        "ingress" = mkOption {
          description =
            "Ingress is a list containing ingress points for the load-balancer. Traffic intended for the service should be sent to these ingress points.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LoadBalancerIngress")));
        };
      };

      config = { "ingress" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference" = {

      options = {
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = { "name" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.LocalVolumeSource" = {

      options = {
        "path" = mkOption {
          description =
            "The full path to the volume on the node For alpha, this path must be a directory Once block as a source is supported, then this path can point to a block device";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.NFSVolumeSource" = {

      options = {
        "path" = mkOption {
          description =
            "Path that is exported by the NFS server. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = types.str;
        };
        "readOnly" = mkOption {
          description =
            "ReadOnly here will force the NFS export to be mounted with read-only permissions. Defaults to false. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = (types.nullOr types.bool);
        };
        "server" = mkOption {
          description =
            "Server is the hostname or IP address of the NFS server. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = types.str;
        };
      };

      config = { "readOnly" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.Namespace" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the behavior of the Namespace. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NamespaceSpec"));
        };
        "status" = mkOption {
          description =
            "Status describes the current status of a Namespace. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NamespaceStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NamespaceList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "Items is the list of Namespace objects in the list. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Namespace"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NamespaceSpec" = {

      options = {
        "finalizers" = mkOption {
          description =
            "Finalizers is an opaque list of values that must be empty to permanently remove object from storage. More info: https://git.k8s.io/community/contributors/design-proposals/namespaces.md#finalizers";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = { "finalizers" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.NamespaceStatus" = {

      options = {
        "phase" = mkOption {
          description =
            "Phase is the current lifecycle phase of the namespace. More info: https://git.k8s.io/community/contributors/design-proposals/namespaces.md#phases";
          type = (types.nullOr types.str);
        };
      };

      config = { "phase" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.Node" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the behavior of a node. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeSpec"));
        };
        "status" = mkOption {
          description =
            "Most recently observed status of the node. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeAddress" = {

      options = {
        "address" = mkOption {
          description = "The node address.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Node address type, one of Hostname, ExternalIP or InternalIP.";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = ''
            The scheduler will prefer to schedule pods to nodes that satisfy the affinity expressions specified by this field, but it may choose a node that violates one or more of the expressions. The node that is most preferred is the one with the greatest sum of weights, i.e. for each node that meets all of the scheduling requirements (resource request, requiredDuringScheduling affinity expressions, etc.), compute a sum by iterating through the elements of this field and adding "weight" to the sum if the node matches the corresponding matchExpressions; the node(s) with the highest sum are the most preferred.'';
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PreferredSchedulingTerm")));
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description =
            "If the affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to an update), the system may or may not try to eventually evict the pod from its node.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeSelector"));
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeCondition" = {

      options = {
        "lastHeartbeatTime" = mkOption {
          description = "Last time we got an update on a given condition.";
          type = (types.nullOr types.str);
        };
        "lastTransitionTime" = mkOption {
          description = "Last time the condition transit from one status to another.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "Human readable message indicating details about last transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "(brief) reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type of node condition.";
          type = types.str;
        };
      };

      config = {
        "lastHeartbeatTime" = mkOverride 1002 null;
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeDaemonEndpoints" = {

      options = {
        "kubeletEndpoint" = mkOption {
          description = "Endpoint on which Kubelet is listening.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.DaemonEndpoint"));
        };
      };

      config = { "kubeletEndpoint" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of nodes";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Node"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeSelector" = {

      options = {
        "nodeSelectorTerms" = mkOption {
          description = "Required. A list of node selector terms. The terms are ORed.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeSelectorTerm"));
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeSelectorRequirement" = {

      options = {
        "key" = mkOption {
          description = "The label key that the selector applies to.";
          type = types.str;
        };
        "operator" = mkOption {
          description =
            "Represents a key's relationship to a set of values. Valid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.";
          type = types.str;
        };
        "values" = mkOption {
          description =
            "An array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. If the operator is Gt or Lt, the values array must have a single element, which will be interpreted as an integer. This array is replaced during a strategic merge patch.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = { "values" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeSelectorTerm" = {

      options = {
        "matchExpressions" = mkOption {
          description =
            "Required. A list of node selector requirements. The requirements are ANDed.";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeSelectorRequirement"));
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeSpec" = {

      options = {
        "externalID" = mkOption {
          description =
            "External ID of the node assigned by some machine database (e.g. a cloud provider). Deprecated.";
          type = (types.nullOr types.str);
        };
        "podCIDR" = mkOption {
          description = "PodCIDR represents the pod IP range assigned to the node.";
          type = (types.nullOr types.str);
        };
        "providerID" = mkOption {
          description =
            "ID of the node assigned by the cloud provider in the format: u003cProviderNameu003e://u003cProviderSpecificNodeIDu003e";
          type = (types.nullOr types.str);
        };
        "taints" = mkOption {
          description = "If specified, the node's taints.";
          type = (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Taint")));
        };
        "unschedulable" = mkOption {
          description =
            "Unschedulable controls node schedulability of new pods. By default, node is schedulable. More info: https://kubernetes.io/docs/concepts/nodes/node/#manual-node-administration";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "externalID" = mkOverride 1002 null;
        "podCIDR" = mkOverride 1002 null;
        "providerID" = mkOverride 1002 null;
        "taints" = mkOverride 1002 null;
        "unschedulable" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeStatus" = {

      options = {
        "addresses" = mkOption {
          description =
            "List of addresses reachable to the node. Queried from cloud provider, if available. More info: https://kubernetes.io/docs/concepts/nodes/node/#addresses";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.NodeAddress" "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "allocatable" = mkOption {
          description =
            "Allocatable represents the resources of a node that are available for scheduling. Defaults to Capacity.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "capacity" = mkOption {
          description =
            "Capacity represents the total resources of a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#capacity";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "conditions" = mkOption {
          description =
            "Conditions is an array of current observed node conditions. More info: https://kubernetes.io/docs/concepts/nodes/node/#condition";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.NodeCondition"
              "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "daemonEndpoints" = mkOption {
          description = "Endpoints of daemons running on the Node.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeDaemonEndpoints"));
        };
        "images" = mkOption {
          description = "List of container images on this node";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerImage")));
        };
        "nodeInfo" = mkOption {
          description =
            "Set of ids/uuids to uniquely identify the node. More info: https://kubernetes.io/docs/concepts/nodes/node/#info";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeSystemInfo"));
        };
        "phase" = mkOption {
          description =
            "NodePhase is the recently observed lifecycle phase of the node. More info: https://kubernetes.io/docs/concepts/nodes/node/#phase The field is never populated, and now is deprecated.";
          type = (types.nullOr types.str);
        };
        "volumesAttached" = mkOption {
          description = "List of volumes that are attached to the node.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AttachedVolume")));
        };
        "volumesInUse" = mkOption {
          description = "List of attachable volumes in use (mounted) by the node.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "addresses" = mkOverride 1002 null;
        "allocatable" = mkOverride 1002 null;
        "capacity" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "daemonEndpoints" = mkOverride 1002 null;
        "images" = mkOverride 1002 null;
        "nodeInfo" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
        "volumesAttached" = mkOverride 1002 null;
        "volumesInUse" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.NodeSystemInfo" = {

      options = {
        "architecture" = mkOption {
          description = "The Architecture reported by the node";
          type = types.str;
        };
        "bootID" = mkOption {
          description = "Boot ID reported by the node.";
          type = types.str;
        };
        "containerRuntimeVersion" = mkOption {
          description =
            "ContainerRuntime Version reported by the node through runtime remote API (e.g. docker://1.5.0).";
          type = types.str;
        };
        "kernelVersion" = mkOption {
          description =
            "Kernel Version reported by the node from 'uname -r' (e.g. 3.16.0-0.bpo.4-amd64).";
          type = types.str;
        };
        "kubeProxyVersion" = mkOption {
          description = "KubeProxy Version reported by the node.";
          type = types.str;
        };
        "kubeletVersion" = mkOption {
          description = "Kubelet Version reported by the node.";
          type = types.str;
        };
        "machineID" = mkOption {
          description =
            "MachineID reported by the node. For unique machine identification in the cluster this field is preferred. Learn more from man(5) machine-id: http://man7.org/linux/man-pages/man5/machine-id.5.html";
          type = types.str;
        };
        "operatingSystem" = mkOption {
          description = "The Operating System reported by the node";
          type = types.str;
        };
        "osImage" = mkOption {
          description =
            "OS Image reported by the node from /etc/os-release (e.g. Debian GNU/Linux 7 (wheezy)).";
          type = types.str;
        };
        "systemUUID" = mkOption {
          description =
            "SystemUUID reported by the node. For unique machine identification MachineID is preferred. This field is specific to Red Hat hosts https://access.redhat.com/documentation/en-US/Red_Hat_Subscription_Management/1/html/RHSM/getting-system-uuid.html";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.ObjectFieldSelector" = {

      options = {
        "apiVersion" = mkOption {
          description =
            ''Version of the schema the FieldPath is written in terms of, defaults to "v1".'';
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "Path of the field to select in the specified API version.";
          type = types.str;
        };
      };

      config = { "apiVersion" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.ObjectReference" = {

      options = {
        "apiVersion" = mkOption {
          description = "API version of the referent.";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = ''
            If referring to a piece of an object instead of an entire object, this string should contain a valid JSON/Go field access statement, such as desiredState.manifest.containers[2]. For example, if the object reference is to a container within a pod, this would take on a value like: "spec.containers{name}" (where "name" refers to the name of the container that triggered the event) or if no container name is specified "spec.containers[2]" (container with index 2 in this pod). This syntax is chosen only to have some well-defined way of referencing a part of an object.'';
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind of the referent. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description =
            "Namespace of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/";
          type = (types.nullOr types.str);
        };
        "resourceVersion" = mkOption {
          description =
            "Specific resourceVersion to which this reference is made, if any. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#concurrency-control-and-consistency";
          type = (types.nullOr types.str);
        };
        "uid" = mkOption {
          description =
            "UID of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#uids";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "fieldPath" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "resourceVersion" = mkOverride 1002 null;
        "uid" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolume" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines a specification of a persistent volume owned by the cluster. Provisioned by an administrator. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeSpec"));
        };
        "status" = mkOption {
          description =
            "Status represents the current information/status for the persistent volume. Populated by the system. Read-only. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistent-volumes";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaim" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the desired characteristics of a volume requested by a pod author. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimSpec"));
        };
        "status" = mkOption {
          description =
            "Status represents the current information/status of a persistent volume claim. Read-only. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "A list of persistent volume claims. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaim"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimSpec" = {

      options = {
        "accessModes" = mkOption {
          description =
            "AccessModes contains the desired access modes the volume should have. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "resources" = mkOption {
          description =
            "Resources represents the minimum resources the volume should have. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceRequirements"));
        };
        "selector" = mkOption {
          description = "A label query over volumes to consider for binding.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "storageClassName" = mkOption {
          description =
            "Name of the StorageClass required by the claim. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description =
            "VolumeName is the binding reference to the PersistentVolume backing this claim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimStatus" = {

      options = {
        "accessModes" = mkOption {
          description =
            "AccessModes contains the actual access modes the volume backing the PVC has. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "capacity" = mkOption {
          description = "Represents the actual resources of the underlying volume.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "phase" = mkOption {
          description = "Phase represents the current phase of PersistentVolumeClaim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "capacity" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimVolumeSource" = {

      options = {
        "claimName" = mkOption {
          description =
            "ClaimName is the name of a PersistentVolumeClaim in the same namespace as the pod using this volume. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "Will force the ReadOnly setting in VolumeMounts. Default false.";
          type = (types.nullOr types.bool);
        };
      };

      config = { "readOnly" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "List of persistent volumes. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolume"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeSpec" = {

      options = {
        "accessModes" = mkOption {
          description =
            "AccessModes contains all ways the volume can be mounted. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes";
          type = (types.nullOr (types.listOf types.str));
        };
        "awsElasticBlockStore" = mkOption {
          description =
            "AWSElasticBlockStore represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AWSElasticBlockStoreVolumeSource"));
        };
        "azureDisk" = mkOption {
          description =
            "AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AzureDiskVolumeSource"));
        };
        "azureFile" = mkOption {
          description =
            "AzureFile represents an Azure File Service mount on the host and bind mount to the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AzureFileVolumeSource"));
        };
        "capacity" = mkOption {
          description =
            "A description of the persistent volume's resources and capacity. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#capacity";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "cephfs" = mkOption {
          description =
            "CephFS represents a Ceph FS mount on the host that shares a pod's lifetime";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.CephFSVolumeSource"));
        };
        "cinder" = mkOption {
          description =
            "Cinder represents a cinder volume attached and mounted on kubelets host machine More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.CinderVolumeSource"));
        };
        "claimRef" = mkOption {
          description =
            "ClaimRef is part of a bi-directional binding between PersistentVolume and PersistentVolumeClaim. Expected to be non-nil when bound. claim.VolumeName is the authoritative bind between PV and PVC. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#binding";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectReference"));
        };
        "fc" = mkOption {
          description =
            "FC represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.FCVolumeSource"));
        };
        "flexVolume" = mkOption {
          description =
            "FlexVolume represents a generic volume resource that is provisioned/attached using an exec based plugin. This is an alpha feature and may change in future.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.FlexVolumeSource"));
        };
        "flocker" = mkOption {
          description =
            "Flocker represents a Flocker volume attached to a kubelet's host machine and exposed to the pod for its usage. This depends on the Flocker control service being running";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.FlockerVolumeSource"));
        };
        "gcePersistentDisk" = mkOption {
          description =
            "GCEPersistentDisk represents a GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod. Provisioned by an admin. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.GCEPersistentDiskVolumeSource"));
        };
        "glusterfs" = mkOption {
          description =
            "Glusterfs represents a Glusterfs volume that is attached to a host and exposed to the pod. Provisioned by an admin. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.GlusterfsVolumeSource"));
        };
        "hostPath" = mkOption {
          description =
            "HostPath represents a directory on the host. Provisioned by a developer or tester. This is useful for single-node development and testing only! On-host storage is not supported in any way and WILL NOT WORK in a multi-node cluster. More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.HostPathVolumeSource"));
        };
        "iscsi" = mkOption {
          description =
            "ISCSI represents an ISCSI Disk resource that is attached to a kubelet's host machine and then exposed to the pod. Provisioned by an admin.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ISCSIVolumeSource"));
        };
        "local" = mkOption {
          description = "Local represents directly-attached storage with node affinity";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalVolumeSource"));
        };
        "nfs" = mkOption {
          description =
            "NFS represents an NFS mount on the host. Provisioned by an admin. More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NFSVolumeSource"));
        };
        "persistentVolumeReclaimPolicy" = mkOption {
          description =
            "What happens to a persistent volume when released from its claim. Valid options are Retain (default) and Recycle. Recycling must be supported by the volume plugin underlying this persistent volume. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#reclaiming";
          type = (types.nullOr types.str);
        };
        "photonPersistentDisk" = mkOption {
          description =
            "PhotonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PhotonPersistentDiskVolumeSource"));
        };
        "portworxVolume" = mkOption {
          description =
            "PortworxVolume represents a portworx volume attached and mounted on kubelets host machine";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PortworxVolumeSource"));
        };
        "quobyte" = mkOption {
          description =
            "Quobyte represents a Quobyte mount on the host that shares a pod's lifetime";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.QuobyteVolumeSource"));
        };
        "rbd" = mkOption {
          description =
            "RBD represents a Rados Block Device mount on the host that shares a pod's lifetime. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.RBDVolumeSource"));
        };
        "scaleIO" = mkOption {
          description =
            "ScaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ScaleIOVolumeSource"));
        };
        "storageClassName" = mkOption {
          description =
            "Name of StorageClass to which this persistent volume belongs. Empty value means that this volume does not belong to any StorageClass.";
          type = (types.nullOr types.str);
        };
        "storageos" = mkOption {
          description =
            "StorageOS represents a StorageOS volume that is attached to the kubelet's host machine and mounted into the pod More info: https://releases.k8s.io/HEAD/examples/volumes/storageos/README.md";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.StorageOSPersistentVolumeSource"));
        };
        "vsphereVolume" = mkOption {
          description =
            "VsphereVolume represents a vSphere volume attached and mounted on kubelets host machine";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.VsphereVirtualDiskVolumeSource"));
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "awsElasticBlockStore" = mkOverride 1002 null;
        "azureDisk" = mkOverride 1002 null;
        "azureFile" = mkOverride 1002 null;
        "capacity" = mkOverride 1002 null;
        "cephfs" = mkOverride 1002 null;
        "cinder" = mkOverride 1002 null;
        "claimRef" = mkOverride 1002 null;
        "fc" = mkOverride 1002 null;
        "flexVolume" = mkOverride 1002 null;
        "flocker" = mkOverride 1002 null;
        "gcePersistentDisk" = mkOverride 1002 null;
        "glusterfs" = mkOverride 1002 null;
        "hostPath" = mkOverride 1002 null;
        "iscsi" = mkOverride 1002 null;
        "local" = mkOverride 1002 null;
        "nfs" = mkOverride 1002 null;
        "persistentVolumeReclaimPolicy" = mkOverride 1002 null;
        "photonPersistentDisk" = mkOverride 1002 null;
        "portworxVolume" = mkOverride 1002 null;
        "quobyte" = mkOverride 1002 null;
        "rbd" = mkOverride 1002 null;
        "scaleIO" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "storageos" = mkOverride 1002 null;
        "vsphereVolume" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeStatus" = {

      options = {
        "message" = mkOption {
          description =
            "A human-readable message indicating details about why the volume is in this state.";
          type = (types.nullOr types.str);
        };
        "phase" = mkOption {
          description =
            "Phase indicates if a volume is available, bound to a claim, or released by a claim. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#phase";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description =
            "Reason is a brief CamelCase string that describes any failure and is meant for machine parsing and tidy display in the CLI.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "message" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PhotonPersistentDiskVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "pdID" = mkOption {
          description = "ID that identifies Photon Controller persistent disk";
          type = types.str;
        };
      };

      config = { "fsType" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.Pod" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Specification of the desired behavior of the pod. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodSpec"));
        };
        "status" = mkOption {
          description =
            "Most recently observed status of the pod. This data may not be up to date. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = ''
            The scheduler will prefer to schedule pods to nodes that satisfy the affinity expressions specified by this field, but it may choose a node that violates one or more of the expressions. The node that is most preferred is the one with the greatest sum of weights, i.e. for each node that meets all of the scheduling requirements (resource request, requiredDuringScheduling affinity expressions, etc.), compute a sum by iterating through the elements of this field and adding "weight" to the sum if the node has pods which matches the corresponding podAffinityTerm; the node(s) with the highest sum are the most preferred.'';
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.WeightedPodAffinityTerm")));
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = ''
            NOT YET IMPLEMENTED. TODO: Uncomment field once it is implemented. If the affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to a pod label update), the system will try to eventually evict the pod from its node. When there are multiple elements, the lists of nodes corresponding to each podAffinityTerm are intersected, i.e. all terms must be satisfied. RequiredDuringSchedulingRequiredDuringExecution []PodAffinityTerm  `json:"requiredDuringSchedulingRequiredDuringExecution,omitempty"` If the affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to a pod label update), the system may or may not try to eventually evict the pod from its node. When there are multiple elements, the lists of nodes corresponding to each podAffinityTerm are intersected, i.e. all terms must be satisfied.'';
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodAffinityTerm")));
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodAffinityTerm" = {

      options = {
        "labelSelector" = mkOption {
          description = "A label query over a set of resources, in this case pods.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "namespaces" = mkOption {
          description = ''
            namespaces specifies which namespaces the labelSelector applies to (matches against); null or empty list means "this pod's namespace"'';
          type = (types.nullOr (types.listOf types.str));
        };
        "topologyKey" = mkOption {
          description = ''
            This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching the labelSelector in the specified namespaces, where co-located is defined as running on a node whose value of the label with key topologyKey matches that of any node on which any of the selected pods is running. For PreferredDuringScheduling pod anti-affinity, empty topologyKey is interpreted as "all topologies" ("all topologies" here means all the topologyKeys indicated by scheduler command-line argument --failure-domains); for affinity and for RequiredDuringScheduling pod anti-affinity, empty topologyKey is not allowed.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "namespaces" = mkOverride 1002 null;
        "topologyKey" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = ''
            The scheduler will prefer to schedule pods to nodes that satisfy the anti-affinity expressions specified by this field, but it may choose a node that violates one or more of the expressions. The node that is most preferred is the one with the greatest sum of weights, i.e. for each node that meets all of the scheduling requirements (resource request, requiredDuringScheduling anti-affinity expressions, etc.), compute a sum by iterating through the elements of this field and adding "weight" to the sum if the node has pods which matches the corresponding podAffinityTerm; the node(s) with the highest sum are the most preferred.'';
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.WeightedPodAffinityTerm")));
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = ''
            NOT YET IMPLEMENTED. TODO: Uncomment field once it is implemented. If the anti-affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the anti-affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to a pod label update), the system will try to eventually evict the pod from its node. When there are multiple elements, the lists of nodes corresponding to each podAffinityTerm are intersected, i.e. all terms must be satisfied. RequiredDuringSchedulingRequiredDuringExecution []PodAffinityTerm  `json:"requiredDuringSchedulingRequiredDuringExecution,omitempty"` If the anti-affinity requirements specified by this field are not met at scheduling time, the pod will not be scheduled onto the node. If the anti-affinity requirements specified by this field cease to be met at some point during pod execution (e.g. due to a pod label update), the system may or may not try to eventually evict the pod from its node. When there are multiple elements, the lists of nodes corresponding to each podAffinityTerm are intersected, i.e. all terms must be satisfied.'';
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodAffinityTerm")));
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodCondition" = {

      options = {
        "lastProbeTime" = mkOption {
          description = "Last time we probed the condition.";
          type = (types.nullOr types.str);
        };
        "lastTransitionTime" = mkOption {
          description = "Last time the condition transitioned from one status to another.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "Human-readable message indicating details about last transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "Unique, one-word, CamelCase reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description =
            "Status is the status of the condition. Can be True, False, Unknown. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions";
          type = types.str;
        };
        "type" = mkOption {
          description =
            "Type is the type of the condition. Currently only Ready. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions";
          type = types.str;
        };
      };

      config = {
        "lastProbeTime" = mkOverride 1002 null;
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "List of pods. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Pod"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodSecurityContext" = {

      options = {
        "fsGroup" = mkOption {
          description = ''
            A special supplemental group that applies to all containers in a pod. Some volume types allow the Kubelet to change the ownership of that volume to be owned by the pod:

            1. The owning GID will be the FSGroup 2. The setgid bit is set (new files created in the volume will be owned by FSGroup) 3. The permission bits are OR'd with rw-rw----

            If unset, the Kubelet will not modify the ownership and permissions of any volume.'';
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description =
            "Indicates that the container must run as a non-root user. If true, the Kubelet will validate the image at runtime to ensure that it does not run as UID 0 (root) and fail to start the container if it does. If unset or false, no such validation will be performed. May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description =
            "The UID to run the entrypoint of the container process. Defaults to user specified in image metadata if unspecified. May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence for that container.";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description =
            "The SELinux context to be applied to all containers. If unspecified, the container runtime will allocate a random SELinux context for each container.  May also be set in SecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence for that container.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SELinuxOptions"));
        };
        "supplementalGroups" = mkOption {
          description =
            "A list of groups applied to the first process run in each container, in addition to the container's primary GID.  If unspecified, no groups will be added to any container.";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "fsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "supplementalGroups" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodSpec" = {

      options = {
        "activeDeadlineSeconds" = mkOption {
          description =
            "Optional duration in seconds the pod may be active on the node relative to StartTime before the system will actively try to mark it failed and kill associated containers. Value must be a positive integer.";
          type = (types.nullOr types.int);
        };
        "affinity" = mkOption {
          description = "If specified, the pod's scheduling constraints";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Affinity"));
        };
        "automountServiceAccountToken" = mkOption {
          description =
            "AutomountServiceAccountToken indicates whether a service account token should be automatically mounted.";
          type = (types.nullOr types.bool);
        };
        "containers" = mkOption {
          description =
            "List of containers belonging to the pod. Containers cannot currently be added or removed. There must be at least one container in a Pod. Cannot be updated.";
          type =
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.Container" "name");
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "dnsPolicy" = mkOption {
          description = ''
            Set DNS policy for containers within the pod. One of 'ClusterFirstWithHostNet', 'ClusterFirst' or 'Default'. Defaults to "ClusterFirst". To have DNS options set along with hostNetwork, you have to specify DNS policy explicitly to 'ClusterFirstWithHostNet'.'';
          type = (types.nullOr types.str);
        };
        "hostAliases" = mkOption {
          description =
            "HostAliases is an optional list of hosts and IPs that will be injected into the pod's hosts file if specified. This is only valid for non-hostNetwork pods.";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.HostAlias" "ip"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "hostIPC" = mkOption {
          description = "Use the host's ipc namespace. Optional: Default to false.";
          type = (types.nullOr types.bool);
        };
        "hostNetwork" = mkOption {
          description =
            "Host networking requested for this pod. Use the host's network namespace. If this option is set, the ports that will be used must be specified. Default to false.";
          type = (types.nullOr types.bool);
        };
        "hostPID" = mkOption {
          description = "Use the host's pid namespace. Optional: Default to false.";
          type = (types.nullOr types.bool);
        };
        "hostname" = mkOption {
          description =
            "Specifies the hostname of the Pod If not specified, the pod's hostname will be set to a system-defined value.";
          type = (types.nullOr types.str);
        };
        "imagePullSecrets" = mkOption {
          description =
            "ImagePullSecrets is an optional list of references to secrets in the same namespace to use for pulling any of the images used by this PodSpec. If specified, these secrets will be passed to individual puller implementations for them to use. For example, in the case of docker, only DockerConfig type secrets are honored. More info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference"
              "name"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "initContainers" = mkOption {
          description =
            "List of initialization containers belonging to the pod. Init containers are executed in order prior to containers being started. If any init container fails, the pod is considered to have failed and is handled according to its restartPolicy. The name for an init container or normal container must be unique among all containers. Init containers may not have Lifecycle actions, Readiness probes, or Liveness probes. The resourceRequirements of an init container are taken into account during scheduling by finding the highest request/limit for each resource type, and then using the max of of that value or the sum of the normal containers. Limits are applied to init containers in a similar fashion. Init containers cannot currently be added or removed. Cannot be updated. More info: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.Container" "name"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "nodeName" = mkOption {
          description =
            "NodeName is a request to schedule this pod onto a specific node. If it is non-empty, the scheduler simply schedules this pod onto that node, assuming that it fits resource requirements.";
          type = (types.nullOr types.str);
        };
        "nodeSelector" = mkOption {
          description =
            "NodeSelector is a selector which must be true for the pod to fit on a node. Selector which must match a node's labels for the pod to be scheduled on that node. More info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "restartPolicy" = mkOption {
          description =
            "Restart policy for all containers within the pod. One of Always, OnFailure, Never. Default to Always. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy";
          type = (types.nullOr types.str);
        };
        "schedulerName" = mkOption {
          description =
            "If specified, the pod will be dispatched by specified scheduler. If not specified, the pod will be dispatched by default scheduler.";
          type = (types.nullOr types.str);
        };
        "securityContext" = mkOption {
          description =
            "SecurityContext holds pod-level security attributes and common container settings. Optional: Defaults to empty.  See type description for default values of each field.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodSecurityContext"));
        };
        "serviceAccount" = mkOption {
          description =
            "DeprecatedServiceAccount is a depreciated alias for ServiceAccountName. Deprecated: Use serviceAccountName instead.";
          type = (types.nullOr types.str);
        };
        "serviceAccountName" = mkOption {
          description =
            "ServiceAccountName is the name of the ServiceAccount to use to run this pod. More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/";
          type = (types.nullOr types.str);
        };
        "subdomain" = mkOption {
          description = ''
            If specified, the fully qualified Pod hostname will be "u003chostnameu003e.u003csubdomainu003e.u003cpod namespaceu003e.svc.u003ccluster domainu003e". If not specified, the pod will not have a domainname at all.'';
          type = (types.nullOr types.str);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description =
            "Optional duration in seconds the pod needs to terminate gracefully. May be decreased in delete request. Value must be non-negative integer. The value zero indicates delete immediately. If this value is nil, the default grace period will be used instead. The grace period is the duration in seconds after the processes running in the pod are sent a termination signal and the time when the processes are forcibly halted with a kill signal. Set this value longer than the expected cleanup time for your process. Defaults to 30 seconds.";
          type = (types.nullOr types.int);
        };
        "tolerations" = mkOption {
          description = "If specified, the pod's tolerations.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Toleration")));
        };
        "volumes" = mkOption {
          description =
            "List of volumes that can be mounted by containers belonging to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.Volume" "name"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
      };

      config = {
        "activeDeadlineSeconds" = mkOverride 1002 null;
        "affinity" = mkOverride 1002 null;
        "automountServiceAccountToken" = mkOverride 1002 null;
        "dnsPolicy" = mkOverride 1002 null;
        "hostAliases" = mkOverride 1002 null;
        "hostIPC" = mkOverride 1002 null;
        "hostNetwork" = mkOverride 1002 null;
        "hostPID" = mkOverride 1002 null;
        "hostname" = mkOverride 1002 null;
        "imagePullSecrets" = mkOverride 1002 null;
        "initContainers" = mkOverride 1002 null;
        "nodeName" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "schedulerName" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccount" = mkOverride 1002 null;
        "serviceAccountName" = mkOverride 1002 null;
        "subdomain" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodStatus" = {

      options = {
        "conditions" = mkOption {
          description =
            "Current service state of pod. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-conditions";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.PodCondition"
              "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "containerStatuses" = mkOption {
          description =
            "The list has one entry per container in the manifest. Each entry is currently the output of `docker inspect`. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-and-container-status";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerStatus")));
        };
        "hostIP" = mkOption {
          description =
            "IP address of the host to which the pod is assigned. Empty if not yet scheduled.";
          type = (types.nullOr types.str);
        };
        "initContainerStatuses" = mkOption {
          description =
            "The list has one entry per init container in the manifest. The most recent successful init container will have ready = true, the most recently started container will have startTime set. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-and-container-status";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ContainerStatus")));
        };
        "message" = mkOption {
          description =
            "A human readable message indicating details about why the pod is in this condition.";
          type = (types.nullOr types.str);
        };
        "phase" = mkOption {
          description =
            "Current condition of the pod. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#pod-phase";
          type = (types.nullOr types.str);
        };
        "podIP" = mkOption {
          description =
            "IP address allocated to the pod. Routable at least within the cluster. Empty if not yet allocated.";
          type = (types.nullOr types.str);
        };
        "qosClass" = mkOption {
          description =
            "The Quality of Service (QOS) classification assigned to the pod based on resource requirements See PodQOSClass type for available QOS classes More info: https://github.com/kubernetes/kubernetes/blob/master/docs/design/resource-qos.md";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description =
            "A brief CamelCase message indicating details about why the pod is in this state. e.g. 'OutOfDisk'";
          type = (types.nullOr types.str);
        };
        "startTime" = mkOption {
          description =
            "RFC 3339 date and time at which the object was acknowledged by the Kubelet. This is before the Kubelet pulled the container image(s) for the pod.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "conditions" = mkOverride 1002 null;
        "containerStatuses" = mkOverride 1002 null;
        "hostIP" = mkOverride 1002 null;
        "initContainerStatuses" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
        "podIP" = mkOverride 1002 null;
        "qosClass" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
        "startTime" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodTemplate" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "template" = mkOption {
          description =
            "Template defines the pods that will be created from this pod template. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "template" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodTemplateList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of pod templates";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplate"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec" = {

      options = {
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Specification of the desired behavior of the pod. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodSpec"));
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PortworxVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            FSType represents the filesystem type to mount Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "VolumeID uniquely identifies a Portworx volume";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.PreferredSchedulingTerm" = {

      options = {
        "preference" = mkOption {
          description = "A node selector term, associated with the corresponding weight.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NodeSelectorTerm");
        };
        "weight" = mkOption {
          description =
            "Weight associated with matching the corresponding nodeSelectorTerm, in the range 1-100.";
          type = types.int;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.api.v1.Probe" = {

      options = {
        "exec" = mkOption {
          description =
            "One and only one of the following should be specified. Exec specifies the action to take.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ExecAction"));
        };
        "failureThreshold" = mkOption {
          description =
            "Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies the http request to perform.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.HTTPGetAction"));
        };
        "initialDelaySeconds" = mkOption {
          description =
            "Number of seconds after the container has started before liveness probes are initiated. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description =
            "How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description =
            "Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description =
            "TCPSocket specifies an action involving a TCP port. TCP hooks not yet supported";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.TCPSocketAction"));
        };
        "timeoutSeconds" = mkOption {
          description =
            "Number of seconds after which the probe times out. Defaults to 1 second. Minimum value is 1. More info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ProjectedVolumeSource" = {

      options = {
        "defaultMode" = mkOption {
          description =
            "Mode bits to use on created files by default. Must be a value between 0 and 0777. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "sources" = mkOption {
          description = "list of volume projections";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.VolumeProjection"));
        };
      };

      config = { "defaultMode" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.QuobyteVolumeSource" = {

      options = {
        "group" = mkOption {
          description = "Group to map volume access to Default is no group";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "ReadOnly here will force the Quobyte volume to be mounted with read-only permissions. Defaults to false.";
          type = (types.nullOr types.bool);
        };
        "registry" = mkOption {
          description =
            "Registry represents a single or multiple Quobyte Registry services specified as a string as host:port pair (multiple entries are separated with commas) which acts as the central registry for volumes";
          type = types.str;
        };
        "user" = mkOption {
          description = "User to map volume access to Defaults to serivceaccount user";
          type = (types.nullOr types.str);
        };
        "volume" = mkOption {
          description =
            "Volume is a string that references an already created Quobyte volume by name.";
          type = types.str;
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.RBDVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type of the volume that you want to mount. Tip: Ensure that the filesystem type is supported by the host operating system. Examples: "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified. More info: https://kubernetes.io/docs/concepts/storage/volumes#rbd'';
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description =
            "The rados image name. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = types.str;
        };
        "keyring" = mkOption {
          description =
            "Keyring is the path to key ring for RBDUser. Default is /etc/ceph/keyring. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
        "monitors" = mkOption {
          description =
            "A collection of Ceph monitors. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = (types.listOf types.str);
        };
        "pool" = mkOption {
          description =
            "The rados pool name. Default is rbd. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "ReadOnly here will force the ReadOnly setting in VolumeMounts. Defaults to false. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description =
            "SecretRef is name of the authentication secret for RBDUser. If provided overrides keyring. Default is nil. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference"));
        };
        "user" = mkOption {
          description =
            "The rados user name. Default is admin. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "keyring" = mkOverride 1002 null;
        "pool" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ReplicationController" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "If the Labels of a ReplicationController are empty, they are defaulted to be the same as the Pod(s) that the replication controller manages. Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the specification of the desired behavior of the replication controller. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerSpec"));
        };
        "status" = mkOption {
          description =
            "Status is the most recently observed status of the replication controller. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerCondition" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "The last time the condition transitioned from one status to another.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "A human readable message indicating details about the transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "The reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type of replication controller condition.";
          type = types.str;
        };
      };

      config = {
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "List of replication controllers. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ReplicationController"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerSpec" = {

      options = {
        "minReadySeconds" = mkOption {
          description =
            "Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Replicas is the number of desired replicas. This is a pointer to distinguish between explicit zero and unspecified. Defaults to 1. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#what-is-a-replicationcontroller";
          type = (types.nullOr types.int);
        };
        "selector" = mkOption {
          description =
            "Selector is a label query over pods that should match the Replicas count. If Selector is empty, it is defaulted to the labels present on the Pod template. Label keys and values that must match in order to be controlled by this replication controller, if empty defaulted to labels on Pod template. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "template" = mkOption {
          description =
            "Template is the object that describes the pod that will be created if insufficient replicas are detected. This takes precedence over a TemplateRef. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec"));
        };
      };

      config = {
        "minReadySeconds" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "template" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerStatus" = {

      options = {
        "availableReplicas" = mkOption {
          description =
            "The number of available replicas (ready for at least minReadySeconds) for this replication controller.";
          type = (types.nullOr types.int);
        };
        "conditions" = mkOption {
          description =
            "Represents the latest available observations of a replication controller's current state.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.kubernetes.pkg.api.v1.ReplicationControllerCondition" "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "fullyLabeledReplicas" = mkOption {
          description =
            "The number of pods that have labels matching the labels of the pod template of the replication controller.";
          type = (types.nullOr types.int);
        };
        "observedGeneration" = mkOption {
          description =
            "ObservedGeneration reflects the generation of the most recently observed replication controller.";
          type = (types.nullOr types.int);
        };
        "readyReplicas" = mkOption {
          description = "The number of ready replicas for this replication controller.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Replicas is the most recently oberved number of replicas. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#what-is-a-replicationcontroller";
          type = types.int;
        };
      };

      config = {
        "availableReplicas" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "fullyLabeledReplicas" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "readyReplicas" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ResourceFieldSelector" = {

      options = {
        "containerName" = mkOption {
          description = "Container name: required for volumes, optional for env vars";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = ''Specifies the output format of the exposed resources, defaults to "1"'';
          type = (types.nullOr types.str);
        };
        "resource" = mkOption {
          description = "Required: resource to select";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ResourceQuota" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the desired quota. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceQuotaSpec"));
        };
        "status" = mkOption {
          description =
            "Status defines the actual enforced quota and its current usage. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceQuotaStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ResourceQuotaList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "Items is a list of ResourceQuota objects. More info: https://git.k8s.io/community/contributors/design-proposals/admission_control_resource_quota.md";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ResourceQuota"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ResourceQuotaSpec" = {

      options = {
        "hard" = mkOption {
          description =
            "Hard is the set of desired hard limits for each named resource. More info: https://git.k8s.io/community/contributors/design-proposals/admission_control_resource_quota.md";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "scopes" = mkOption {
          description =
            "A collection of filters that must match each object tracked by a quota. If not specified, the quota matches all objects.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "hard" = mkOverride 1002 null;
        "scopes" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ResourceQuotaStatus" = {

      options = {
        "hard" = mkOption {
          description =
            "Hard is the set of enforced hard limits for each named resource. More info: https://git.k8s.io/community/contributors/design-proposals/admission_control_resource_quota.md";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "used" = mkOption {
          description =
            "Used is the current observed total usage of the resource in the namespace.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "hard" = mkOverride 1002 null;
        "used" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ResourceRequirements" = {

      options = {
        "limits" = mkOption {
          description =
            "Limits describes the maximum amount of compute resources allowed. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "requests" = mkOption {
          description =
            "Requests describes the minimum amount of compute resources required. If Requests is omitted for a container, it defaults to Limits if that is explicitly specified, otherwise to an implementation-defined value. More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SELinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "Level is SELinux level label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "Role is a SELinux role label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "Type is a SELinux type label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "User is a SELinux user label that applies to the container.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ScaleIOVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "gateway" = mkOption {
          description = "The host address of the ScaleIO API Gateway.";
          type = types.str;
        };
        "protectionDomain" = mkOption {
          description = ''
            The name of the Protection Domain for the configured storage (defaults to "default").'';
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description =
            "SecretRef references to the secret for ScaleIO user and other sensitive information. If this is not provided, Login operation will fail.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference");
        };
        "sslEnabled" = mkOption {
          description = "Flag to enable/disable SSL communication with Gateway, default false";
          type = (types.nullOr types.bool);
        };
        "storageMode" = mkOption {
          description = ''
            Indicates whether the storage for a volume should be thick or thin (defaults to "thin").'';
          type = (types.nullOr types.str);
        };
        "storagePool" = mkOption {
          description =
            ''The Storage Pool associated with the protection domain (defaults to "default").'';
          type = (types.nullOr types.str);
        };
        "system" = mkOption {
          description = "The name of the storage system as configured in ScaleIO.";
          type = types.str;
        };
        "volumeName" = mkOption {
          description =
            "The name of a volume already created in the ScaleIO system that is associated with this volume source.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "protectionDomain" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "sslEnabled" = mkOverride 1002 null;
        "storageMode" = mkOverride 1002 null;
        "storagePool" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Secret" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "data" = mkOption {
          description =
            "Data contains the secret data. Each key must consist of alphanumeric characters, '-', '_' or '.'. The serialized form of the secret data is a base64 encoded string, representing the arbitrary (possibly non-string) data value here. Described in https://tools.ietf.org/html/rfc4648#section-4";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "stringData" = mkOption {
          description =
            "stringData allows specifying non-binary secret data in string form. It is provided as a write-only convenience method. All keys and values are merged into the data field on write, overwriting any existing values. It is never output when reading from the API.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "type" = mkOption {
          description = "Used to facilitate programmatic handling of secret data.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "data" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "stringData" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SecretEnvSource" = {

      options = {
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SecretKeySelector" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or it's key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SecretList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "Items is a list of secret objects. More info: https://kubernetes.io/docs/concepts/configuration/secret";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Secret"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SecretProjection" = {

      options = {
        "items" = mkOption {
          description =
            "If unspecified, each key-value pair in the Data field of the referenced Secret will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the Secret, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.KeyToPath")));
        };
        "name" = mkOption {
          description =
            "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SecretVolumeSource" = {

      options = {
        "defaultMode" = mkOption {
          description =
            "Optional: mode bits to use on created files by default. Must be a value between 0 and 0777. Defaults to 0644. Directories within the path are not affected by this setting. This might be in conflict with other options that affect the file mode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description =
            "If unspecified, each key-value pair in the Data field of the referenced Secret will be projected into the volume as a file whose name is the key and content is the value. If specified, the listed keys will be projected into the specified paths, and unlisted keys will not be present. If a key is specified which is not present in the Secret, the volume setup will error unless it is marked optional. Paths must be relative and may not contain the '..' path or start with '..'.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.KeyToPath")));
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or it's keys must be defined";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description =
            "Name of the secret in the pod's namespace to use. More info: https://kubernetes.io/docs/concepts/storage/volumes#secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.SecurityContext" = {

      options = {
        "capabilities" = mkOption {
          description =
            "The capabilities to add/drop when running containers. Defaults to the default set of capabilities granted by the container runtime.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Capabilities"));
        };
        "privileged" = mkOption {
          description =
            "Run container in privileged mode. Processes in privileged containers are essentially equivalent to root on the host. Defaults to false.";
          type = (types.nullOr types.bool);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "Whether this container has a read-only root filesystem. Default is false.";
          type = (types.nullOr types.bool);
        };
        "runAsNonRoot" = mkOption {
          description =
            "Indicates that the container must run as a non-root user. If true, the Kubelet will validate the image at runtime to ensure that it does not run as UID 0 (root) and fail to start the container if it does. If unset or false, no such validation will be performed. May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description =
            "The UID to run the entrypoint of the container process. Defaults to user specified in image metadata if unspecified. May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description =
            "The SELinux context to be applied to the container. If unspecified, the container runtime will allocate a random SELinux context for each container.  May also be set in PodSecurityContext.  If set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SELinuxOptions"));
        };
      };

      config = {
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Service" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the behavior of a service. https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ServiceSpec"));
        };
        "status" = mkOption {
          description =
            "Most recently observed status of the service. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ServiceStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ServiceAccount" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "automountServiceAccountToken" = mkOption {
          description =
            "AutomountServiceAccountToken indicates whether pods running as this service account should have an API token automatically mounted. Can be overridden at the pod level.";
          type = (types.nullOr types.bool);
        };
        "imagePullSecrets" = mkOption {
          description =
            "ImagePullSecrets is a list of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount. ImagePullSecrets are distinct from Secrets because Secrets can be mounted in the pod, but ImagePullSecrets are only accessed by the kubelet. More info: https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference")));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "secrets" = mkOption {
          description =
            "Secrets is the list of secrets allowed to be used by pods running using this ServiceAccount. More info: https://kubernetes.io/docs/concepts/configuration/secret";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.ObjectReference"
              "name"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "automountServiceAccountToken" = mkOverride 1002 null;
        "imagePullSecrets" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "secrets" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ServiceAccountList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "List of ServiceAccounts. More info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ServiceAccount"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ServiceList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of services";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Service"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ServicePort" = {

      options = {
        "name" = mkOption {
          description =
            "The name of this port within the service. This must be a DNS_LABEL. All ports within a ServiceSpec must have unique names. This maps to the 'Name' field in EndpointPort objects. Optional if only one ServicePort is defined on this service.";
          type = (types.nullOr types.str);
        };
        "nodePort" = mkOption {
          description =
            "The port on each node on which this service is exposed when type=NodePort or LoadBalancer. Usually assigned by the system. If specified, it will be allocated to the service if unused or else creation of the service will fail. Default is to auto-allocate a port if the ServiceType of this Service requires one. More info: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport";
          type = (types.nullOr types.int);
        };
        "port" = mkOption {
          description = "The port that will be exposed by this service.";
          type = types.int;
        };
        "protocol" = mkOption {
          description =
            ''The IP protocol for this port. Supports "TCP" and "UDP". Default is TCP.'';
          type = (types.nullOr types.str);
        };
        "targetPort" = mkOption {
          description =
            "Number or name of the port to access on the pods targeted by the service. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME. If this is a string, it will be looked up as a named port in the target Pod's container ports. If this is not specified, the value of the 'port' field is used (an identity map). This field is ignored for services with clusterIP=None, and should be omitted or set equal to the 'port' field. More info: https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "nodePort" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
        "targetPort" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ServiceSpec" = {

      options = {
        "clusterIP" = mkOption {
          description = ''
            clusterIP is the IP address of the service and is usually assigned randomly by the master. If an address is specified manually and is not in use by others, it will be allocated to the service; otherwise, creation of the service will fail. This field can not be changed through updates. Valid values are "None", empty string (""), or a valid IP address. "None" can be specified for headless services when proxying is not required. Only applies to types ClusterIP, NodePort, and LoadBalancer. Ignored if type is ExternalName. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies'';
          type = (types.nullOr types.str);
        };
        "externalIPs" = mkOption {
          description =
            "externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service.  These IPs are not managed by Kubernetes.  The user is responsible for ensuring that traffic arrives at a node with this IP.  A common example is external load-balancers that are not part of the Kubernetes system.";
          type = (types.nullOr (types.listOf types.str));
        };
        "externalName" = mkOption {
          description =
            "externalName is the external reference that kubedns or equivalent will return as a CNAME record for this service. No proxying will be involved. Must be a valid DNS name and requires Type to be ExternalName.";
          type = (types.nullOr types.str);
        };
        "externalTrafficPolicy" = mkOption {
          description = ''
            externalTrafficPolicy denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints. "Local" preserves the client source IP and avoids a second hop for LoadBalancer and Nodeport type services, but risks potentially imbalanced traffic spreading. "Cluster" obscures the client source IP and may cause a second hop to another node, but should have good overall load-spreading.'';
          type = (types.nullOr types.str);
        };
        "healthCheckNodePort" = mkOption {
          description =
            "healthCheckNodePort specifies the healthcheck nodePort for the service. If not specified, HealthCheckNodePort is created by the service api backend with the allocated nodePort. Will use user-specified nodePort value if specified by the client. Only effects when Type is set to LoadBalancer and ExternalTrafficPolicy is set to Local.";
          type = (types.nullOr types.int);
        };
        "loadBalancerIP" = mkOption {
          description =
            "Only applies to Service Type: LoadBalancer LoadBalancer will get created with the IP specified in this field. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature.";
          type = (types.nullOr types.str);
        };
        "loadBalancerSourceRanges" = mkOption {
          description = ''
            If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature." More info: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/'';
          type = (types.nullOr (types.listOf types.str));
        };
        "ports" = mkOption {
          description =
            "The list of ports that are exposed by this service. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.api.v1.ServicePort" "port"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "selector" = mkOption {
          description =
            "Route service traffic to pods with label keys and values matching this selector. If empty or not present, the service is assumed to have an external process managing its endpoints, which Kubernetes will not modify. Only applies to types ClusterIP, NodePort, and LoadBalancer. Ignored if type is ExternalName. More info: https://kubernetes.io/docs/concepts/services-networking/service/";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "sessionAffinity" = mkOption {
          description = ''
            Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies'';
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = ''
            type determines how the Service is exposed. Defaults to ClusterIP. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. "ExternalName" maps to the specified externalName. "ClusterIP" allocates a cluster-internal IP address for load-balancing to endpoints. Endpoints are determined by the selector or if that is not specified, by manual construction of an Endpoints object. If clusterIP is "None", no virtual IP is allocated and the endpoints are published as a set of endpoints rather than a stable IP. "NodePort" builds on ClusterIP and allocates a port on every node which routes to the clusterIP. "LoadBalancer" builds on NodePort and creates an external load-balancer (if supported in the current cloud) which routes to the clusterIP. More info: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services---service-types'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "clusterIP" = mkOverride 1002 null;
        "externalIPs" = mkOverride 1002 null;
        "externalName" = mkOverride 1002 null;
        "externalTrafficPolicy" = mkOverride 1002 null;
        "healthCheckNodePort" = mkOverride 1002 null;
        "loadBalancerIP" = mkOverride 1002 null;
        "loadBalancerSourceRanges" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "sessionAffinity" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.ServiceStatus" = {

      options = {
        "loadBalancer" = mkOption {
          description =
            "LoadBalancer contains the current status of the load-balancer, if one is present.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LoadBalancerStatus"));
        };
      };

      config = { "loadBalancer" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.StorageOSPersistentVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description =
            "SecretRef specifies the secret to use for obtaining the StorageOS API credentials.  If not specified, default values will be attempted.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectReference"));
        };
        "volumeName" = mkOption {
          description =
            "VolumeName is the human-readable name of the StorageOS volume.  Volume names are only unique within a namespace.";
          type = (types.nullOr types.str);
        };
        "volumeNamespace" = mkOption {
          description = ''
            VolumeNamespace specifies the scope of the volume within StorageOS.  If no namespace is specified then the Pod's namespace will be used.  This allows the Kubernetes name scoping to be mirrored within StorageOS for tighter integration. Set VolumeName to any name to override the default behaviour. Set to "default" if you are not using namespaces within StorageOS. Namespaces that do not pre-exist within StorageOS will be created.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
        "volumeNamespace" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.StorageOSVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description =
            "Defaults to false (read/write). ReadOnly here will force the ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description =
            "SecretRef specifies the secret to use for obtaining the StorageOS API credentials.  If not specified, default values will be attempted.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LocalObjectReference"));
        };
        "volumeName" = mkOption {
          description =
            "VolumeName is the human-readable name of the StorageOS volume.  Volume names are only unique within a namespace.";
          type = (types.nullOr types.str);
        };
        "volumeNamespace" = mkOption {
          description = ''
            VolumeNamespace specifies the scope of the volume within StorageOS.  If no namespace is specified then the Pod's namespace will be used.  This allows the Kubernetes name scoping to be mirrored within StorageOS for tighter integration. Set VolumeName to any name to override the default behaviour. Set to "default" if you are not using namespaces within StorageOS. Namespaces that do not pre-exist within StorageOS will be created.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
        "volumeNamespace" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.TCPSocketAction" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description =
            "Number or name of the port to access on the container. Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = { "host" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.api.v1.Taint" = {

      options = {
        "effect" = mkOption {
          description =
            "Required. The effect of the taint on pods that do not tolerate the taint. Valid effects are NoSchedule, PreferNoSchedule and NoExecute.";
          type = types.str;
        };
        "key" = mkOption {
          description = "Required. The taint key to be applied to a node.";
          type = types.str;
        };
        "timeAdded" = mkOption {
          description =
            "TimeAdded represents the time at which the taint was added. It is only written for NoExecute taints.";
          type = (types.nullOr types.str);
        };
        "value" = mkOption {
          description = "Required. The taint value corresponding to the taint key.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "timeAdded" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Toleration" = {

      options = {
        "effect" = mkOption {
          description =
            "Effect indicates the taint effect to match. Empty means match all taint effects. When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.";
          type = (types.nullOr types.str);
        };
        "key" = mkOption {
          description =
            "Key is the taint key that the toleration applies to. Empty means match all taint keys. If the key is empty, operator must be Exists; this combination means to match all values and all keys.";
          type = (types.nullOr types.str);
        };
        "operator" = mkOption {
          description =
            "Operator represents a key's relationship to the value. Valid operators are Exists and Equal. Defaults to Equal. Exists is equivalent to wildcard for value, so that a pod can tolerate all taints of a particular category.";
          type = (types.nullOr types.str);
        };
        "tolerationSeconds" = mkOption {
          description =
            "TolerationSeconds represents the period of time the toleration (which must be of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default, it is not set, which means tolerate the taint forever (do not evict). Zero and negative values will be treated as 0 (evict immediately) by the system.";
          type = (types.nullOr types.int);
        };
        "value" = mkOption {
          description =
            "Value is the taint value the toleration matches to. If the operator is Exists, the value should be empty, otherwise just a regular string.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "effect" = mkOverride 1002 null;
        "key" = mkOverride 1002 null;
        "operator" = mkOverride 1002 null;
        "tolerationSeconds" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.Volume" = {

      options = {
        "awsElasticBlockStore" = mkOption {
          description =
            "AWSElasticBlockStore represents an AWS Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AWSElasticBlockStoreVolumeSource"));
        };
        "azureDisk" = mkOption {
          description =
            "AzureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AzureDiskVolumeSource"));
        };
        "azureFile" = mkOption {
          description =
            "AzureFile represents an Azure File Service mount on the host and bind mount to the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.AzureFileVolumeSource"));
        };
        "cephfs" = mkOption {
          description =
            "CephFS represents a Ceph FS mount on the host that shares a pod's lifetime";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.CephFSVolumeSource"));
        };
        "cinder" = mkOption {
          description =
            "Cinder represents a cinder volume attached and mounted on kubelets host machine More info: https://releases.k8s.io/HEAD/examples/mysql-cinder-pd/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.CinderVolumeSource"));
        };
        "configMap" = mkOption {
          description = "ConfigMap represents a configMap that should populate this volume";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ConfigMapVolumeSource"));
        };
        "downwardAPI" = mkOption {
          description =
            "DownwardAPI represents downward API about the pod that should populate this volume";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.DownwardAPIVolumeSource"));
        };
        "emptyDir" = mkOption {
          description =
            "EmptyDir represents a temporary directory that shares a pod's lifetime. More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EmptyDirVolumeSource"));
        };
        "fc" = mkOption {
          description =
            "FC represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.FCVolumeSource"));
        };
        "flexVolume" = mkOption {
          description =
            "FlexVolume represents a generic volume resource that is provisioned/attached using an exec based plugin. This is an alpha feature and may change in future.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.FlexVolumeSource"));
        };
        "flocker" = mkOption {
          description =
            "Flocker represents a Flocker volume attached to a kubelet's host machine. This depends on the Flocker control service being running";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.FlockerVolumeSource"));
        };
        "gcePersistentDisk" = mkOption {
          description =
            "GCEPersistentDisk represents a GCE Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.GCEPersistentDiskVolumeSource"));
        };
        "gitRepo" = mkOption {
          description = "GitRepo represents a git repository at a particular revision.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.GitRepoVolumeSource"));
        };
        "glusterfs" = mkOption {
          description =
            "Glusterfs represents a Glusterfs mount on the host that shares a pod's lifetime. More info: https://releases.k8s.io/HEAD/examples/volumes/glusterfs/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.GlusterfsVolumeSource"));
        };
        "hostPath" = mkOption {
          description =
            "HostPath represents a pre-existing file or directory on the host machine that is directly exposed to the container. This is generally used for system agents or other privileged things that are allowed to see the host machine. Most containers will NOT need this. More info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.HostPathVolumeSource"));
        };
        "iscsi" = mkOption {
          description =
            "ISCSI represents an ISCSI Disk resource that is attached to a kubelet's host machine and then exposed to the pod. More info: https://releases.k8s.io/HEAD/examples/volumes/iscsi/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ISCSIVolumeSource"));
        };
        "name" = mkOption {
          description =
            "Volume's name. Must be a DNS_LABEL and unique within the pod. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = types.str;
        };
        "nfs" = mkOption {
          description =
            "NFS represents an NFS mount on the host that shares a pod's lifetime More info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.NFSVolumeSource"));
        };
        "persistentVolumeClaim" = mkOption {
          description =
            "PersistentVolumeClaimVolumeSource represents a reference to a PersistentVolumeClaim in the same namespace. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaimVolumeSource"));
        };
        "photonPersistentDisk" = mkOption {
          description =
            "PhotonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PhotonPersistentDiskVolumeSource"));
        };
        "portworxVolume" = mkOption {
          description =
            "PortworxVolume represents a portworx volume attached and mounted on kubelets host machine";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PortworxVolumeSource"));
        };
        "projected" = mkOption {
          description = "Items for all in one resources secrets, configmaps, and downward API";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ProjectedVolumeSource"));
        };
        "quobyte" = mkOption {
          description =
            "Quobyte represents a Quobyte mount on the host that shares a pod's lifetime";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.QuobyteVolumeSource"));
        };
        "rbd" = mkOption {
          description =
            "RBD represents a Rados Block Device mount on the host that shares a pod's lifetime. More info: https://releases.k8s.io/HEAD/examples/volumes/rbd/README.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.RBDVolumeSource"));
        };
        "scaleIO" = mkOption {
          description =
            "ScaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ScaleIOVolumeSource"));
        };
        "secret" = mkOption {
          description =
            "Secret represents a secret that should populate this volume. More info: https://kubernetes.io/docs/concepts/storage/volumes#secret";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SecretVolumeSource"));
        };
        "storageos" = mkOption {
          description =
            "StorageOS represents a StorageOS volume attached and mounted on Kubernetes nodes.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.StorageOSVolumeSource"));
        };
        "vsphereVolume" = mkOption {
          description =
            "VsphereVolume represents a vSphere volume attached and mounted on kubelets host machine";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.api.v1.VsphereVirtualDiskVolumeSource"));
        };
      };

      config = {
        "awsElasticBlockStore" = mkOverride 1002 null;
        "azureDisk" = mkOverride 1002 null;
        "azureFile" = mkOverride 1002 null;
        "cephfs" = mkOverride 1002 null;
        "cinder" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "emptyDir" = mkOverride 1002 null;
        "fc" = mkOverride 1002 null;
        "flexVolume" = mkOverride 1002 null;
        "flocker" = mkOverride 1002 null;
        "gcePersistentDisk" = mkOverride 1002 null;
        "gitRepo" = mkOverride 1002 null;
        "glusterfs" = mkOverride 1002 null;
        "hostPath" = mkOverride 1002 null;
        "iscsi" = mkOverride 1002 null;
        "nfs" = mkOverride 1002 null;
        "persistentVolumeClaim" = mkOverride 1002 null;
        "photonPersistentDisk" = mkOverride 1002 null;
        "portworxVolume" = mkOverride 1002 null;
        "projected" = mkOverride 1002 null;
        "quobyte" = mkOverride 1002 null;
        "rbd" = mkOverride 1002 null;
        "scaleIO" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "storageos" = mkOverride 1002 null;
        "vsphereVolume" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.VolumeMount" = {

      options = {
        "mountPath" = mkOption {
          description =
            "Path within the container at which the volume should be mounted.  Must not contain ':'.";
          type = types.str;
        };
        "name" = mkOption {
          description = "This must match the Name of a Volume.";
          type = types.str;
        };
        "readOnly" = mkOption {
          description =
            "Mounted read-only if true, read-write otherwise (false or unspecified). Defaults to false.";
          type = (types.nullOr types.bool);
        };
        "subPath" = mkOption {
          description = ''
            Path within the volume from which the container's volume should be mounted. Defaults to "" (volume's root).'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.VolumeProjection" = {

      options = {
        "configMap" = mkOption {
          description = "information about the configMap data to project";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ConfigMapProjection"));
        };
        "downwardAPI" = mkOption {
          description = "information about the downwardAPI data to project";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.DownwardAPIProjection"));
        };
        "secret" = mkOption {
          description = "information about the secret data to project";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SecretProjection"));
        };
      };

      config = {
        "configMap" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.VsphereVirtualDiskVolumeSource" = {

      options = {
        "fsType" = mkOption {
          description = ''
            Filesystem type to mount. Must be a filesystem type supported by the host operating system. Ex. "ext4", "xfs", "ntfs". Implicitly inferred to be "ext4" if unspecified.'';
          type = (types.nullOr types.str);
        };
        "storagePolicyID" = mkOption {
          description =
            "Storage Policy Based Management (SPBM) profile ID associated with the StoragePolicyName.";
          type = (types.nullOr types.str);
        };
        "storagePolicyName" = mkOption {
          description = "Storage Policy Based Management (SPBM) profile name.";
          type = (types.nullOr types.str);
        };
        "volumePath" = mkOption {
          description = "Path that identifies vSphere volume vmdk";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "storagePolicyID" = mkOverride 1002 null;
        "storagePolicyName" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.api.v1.WeightedPodAffinityTerm" = {

      options = {
        "podAffinityTerm" = mkOption {
          description = "Required. A pod affinity term, associated with the corresponding weight.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodAffinityTerm");
        };
        "weight" = mkOption {
          description =
            "weight associated with matching the corresponding podAffinityTerm, in the range 1-100.";
          type = types.int;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.AdmissionHookClientConfig" = {

      options = {
        "caBundle" = mkOption {
          description =
            "CABundle is a PEM encoded CA bundle which will be used to validate webhook's server certificate. Required";
          type = types.str;
        };
        "service" = mkOption {
          description =
            "Service is a reference to the service for this webhook. If there is only one port open for the service, that port will be used. If there are multiple ports open, port 443 will be used if it is open, otherwise it is an error. Required";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ServiceReference");
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHook" = {

      options = {
        "clientConfig" = mkOption {
          description = "ClientConfig defines how to communicate with the hook. Required";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.AdmissionHookClientConfig");
        };
        "failurePolicy" = mkOption {
          description =
            "FailurePolicy defines how unrecognized errors from the admission endpoint are handled - allowed values are Ignore or Fail. Defaults to Ignore.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = ''
            The name of the external admission webhook. Name should be fully qualified, e.g., imagepolicy.kubernetes.io, where "imagepolicy" is the name of the webhook, and kubernetes.io is the name of the organization. Required.'';
          type = types.str;
        };
        "rules" = mkOption {
          description =
            "Rules describes what operations on what resources/subresources the webhook cares about. The webhook cares about an operation if it matches _any_ Rule.";
          type = (types.nullOr (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.RuleWithOperations")));
        };
      };

      config = {
        "failurePolicy" = mkOverride 1002 null;
        "rules" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHookConfiguration" =
      {

        options = {
          "apiVersion" = mkOption {
            description =
              "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
            type = (types.nullOr types.str);
          };
          "externalAdmissionHooks" = mkOption {
            description =
              "ExternalAdmissionHooks is a list of external admission webhooks and the affected resources and operations.";
            type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
              "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHook"
              "name"));
            apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
          };
          "kind" = mkOption {
            description =
              "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
            type = (types.nullOr types.str);
          };
          "metadata" = mkOption {
            description =
              "Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.";
            type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
          };
        };

        config = {
          "apiVersion" = mkOverride 1002 null;
          "externalAdmissionHooks" = mkOverride 1002 null;
          "kind" = mkOverride 1002 null;
          "metadata" = mkOverride 1002 null;
        };

      };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHookConfigurationList" =
      {

        options = {
          "apiVersion" = mkOption {
            description =
              "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
            type = (types.nullOr types.str);
          };
          "items" = mkOption {
            description = "List of ExternalAdmissionHookConfiguration.";
            type = (types.listOf (submoduleOf
              "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHookConfiguration"));
          };
          "kind" = mkOption {
            description =
              "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
            type = (types.nullOr types.str);
          };
          "metadata" = mkOption {
            description =
              "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
            type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
          };
        };

        config = {
          "apiVersion" = mkOverride 1002 null;
          "kind" = mkOverride 1002 null;
          "metadata" = mkOverride 1002 null;
        };

      };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.Initializer" = {

      options = {
        "failurePolicy" = mkOption {
          description = ''
            FailurePolicy defines what happens if the responsible initializer controller fails to takes action. Allowed values are Ignore, or Fail. If "Ignore" is set, initializer is removed from the initializers list of an object if the timeout is reached; If "Fail" is set, admissionregistration returns timeout error if the timeout is reached.'';
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = ''
            Name is the identifier of the initializer. It will be added to the object that needs to be initialized. Name should be fully qualified, e.g., alwayspullimages.kubernetes.io, where "alwayspullimages" is the name of the webhook, and kubernetes.io is the name of the organization. Required'';
          type = types.str;
        };
        "rules" = mkOption {
          description =
            "Rules describes what resources/subresources the initializer cares about. The initializer cares about an operation if it matches _any_ Rule. Rule.Resources must not include subresources.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.Rule")));
        };
      };

      config = {
        "failurePolicy" = mkOverride 1002 null;
        "rules" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.InitializerConfiguration" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "initializers" = mkOption {
          description =
            "Initializers is a list of resources and their default initializers Order-sensitive. When merging multiple InitializerConfigurations, we sort the initializers from different InitializerConfigurations by the name of the InitializerConfigurations; the order of the initializers from the same InitializerConfiguration is preserved.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.Initializer" "name"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "initializers" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.InitializerConfigurationList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "List of InitializerConfiguration.";
          type = (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.InitializerConfiguration"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.Rule" = {

      options = {
        "apiGroups" = mkOption {
          description =
            "APIGroups is the API groups the resources belong to. '*' is all groups. If '*' is present, the length of the slice must be one. Required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "apiVersions" = mkOption {
          description =
            "APIVersions is the API versions the resources belong to. '*' is all versions. If '*' is present, the length of the slice must be one. Required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "resources" = mkOption {
          description = ''
            Resources is a list of resources this rule applies to.

            For example: 'pods' means pods. 'pods/log' means the log subresource of pods. '*' means all resources, but not subresources. 'pods/*' means all subresources of pods. '*/scale' means all scale subresources. '*/*' means all resources and their subresources.

            If wildcard is present, the validation rule will ensure resources do not overlap with each other.

            Depending on the enclosing object, subresources might not be allowed. Required.'';
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "apiGroups" = mkOverride 1002 null;
        "apiVersions" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.RuleWithOperations" = {

      options = {
        "apiGroups" = mkOption {
          description =
            "APIGroups is the API groups the resources belong to. '*' is all groups. If '*' is present, the length of the slice must be one. Required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "apiVersions" = mkOption {
          description =
            "APIVersions is the API versions the resources belong to. '*' is all versions. If '*' is present, the length of the slice must be one. Required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "operations" = mkOption {
          description =
            "Operations is the operations the admission hook cares about - CREATE, UPDATE, or * for all operations. If '*' is present, the length of the slice must be one. Required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "resources" = mkOption {
          description = ''
            Resources is a list of resources this rule applies to.

            For example: 'pods' means pods. 'pods/log' means the log subresource of pods. '*' means all resources, but not subresources. 'pods/*' means all subresources of pods. '*/scale' means all scale subresources. '*/*' means all resources and their subresources.

            If wildcard is present, the validation rule will ensure resources do not overlap with each other.

            Depending on the enclosing object, subresources might not be allowed. Required.'';
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "apiGroups" = mkOverride 1002 null;
        "apiVersions" = mkOverride 1002 null;
        "operations" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ServiceReference" = {

      options = {
        "name" = mkOption {
          description = "Name is the name of the service Required";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace is the namespace of the service Required";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ControllerRevision" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "data" = mkOption {
          description = "Data is the serialized representation of the state.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.runtime.RawExtension"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "revision" = mkOption {
          description = "Revision indicates the revision of the state represented by Data.";
          type = types.int;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "data" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ControllerRevisionList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of ControllerRevisions";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ControllerRevision"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.Deployment" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the Deployment.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentSpec"));
        };
        "status" = mkOption {
          description = "Most recently observed status of the Deployment.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentCondition" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "Last time the condition transitioned from one status to another.";
          type = (types.nullOr types.str);
        };
        "lastUpdateTime" = mkOption {
          description = "The last time this condition was updated.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "A human readable message indicating details about the transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "The reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type of deployment condition.";
          type = types.str;
        };
      };

      config = {
        "lastTransitionTime" = mkOverride 1002 null;
        "lastUpdateTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of Deployments.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.Deployment"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard list metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentRollback" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Required: This must match the Name of a deployment.";
          type = types.str;
        };
        "rollbackTo" = mkOption {
          description = "The config of this deployment rollback.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollbackConfig");
        };
        "updatedAnnotations" = mkOption {
          description = "The annotations to be updated to a deployment";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "updatedAnnotations" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentSpec" = {

      options = {
        "minReadySeconds" = mkOption {
          description =
            "Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)";
          type = (types.nullOr types.int);
        };
        "paused" = mkOption {
          description = "Indicates that the deployment is paused.";
          type = (types.nullOr types.bool);
        };
        "progressDeadlineSeconds" = mkOption {
          description =
            "The maximum time in seconds for a deployment to make progress before it is considered to be failed. The deployment controller will continue to process failed deployments and a condition with a ProgressDeadlineExceeded reason will be surfaced in the deployment status. Once autoRollback is implemented, the deployment controller will automatically rollback failed deployments. Note that progress will not be estimated during the time a deployment is paused. Defaults to 600s.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Number of desired pods. This is a pointer to distinguish between explicit zero and not specified. Defaults to 1.";
          type = (types.nullOr types.int);
        };
        "revisionHistoryLimit" = mkOption {
          description =
            "The number of old ReplicaSets to retain to allow rollback. This is a pointer to distinguish between explicit zero and not specified. Defaults to 2.";
          type = (types.nullOr types.int);
        };
        "rollbackTo" = mkOption {
          description =
            "The config this deployment is rolling back to. Will be cleared after rollback is done.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollbackConfig"));
        };
        "selector" = mkOption {
          description =
            "Label selector for pods. Existing ReplicaSets whose pods are selected by this will be the ones affected by this deployment.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "strategy" = mkOption {
          description = "The deployment strategy to use to replace existing pods with new ones.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentStrategy"));
        };
        "template" = mkOption {
          description = "Template describes the pods that will be created.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec");
        };
      };

      config = {
        "minReadySeconds" = mkOverride 1002 null;
        "paused" = mkOverride 1002 null;
        "progressDeadlineSeconds" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "revisionHistoryLimit" = mkOverride 1002 null;
        "rollbackTo" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "strategy" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentStatus" = {

      options = {
        "availableReplicas" = mkOption {
          description =
            "Total number of available pods (ready for at least minReadySeconds) targeted by this deployment.";
          type = (types.nullOr types.int);
        };
        "collisionCount" = mkOption {
          description =
            "Count of hash collisions for the Deployment. The Deployment controller uses this field as a collision avoidance mechanism when it needs to create the name for the newest ReplicaSet.";
          type = (types.nullOr types.int);
        };
        "conditions" = mkOption {
          description =
            "Represents the latest available observations of a deployment's current state.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentCondition" "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "observedGeneration" = mkOption {
          description = "The generation observed by the deployment controller.";
          type = (types.nullOr types.int);
        };
        "readyReplicas" = mkOption {
          description = "Total number of ready pods targeted by this deployment.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Total number of non-terminated pods targeted by this deployment (their labels match the selector).";
          type = (types.nullOr types.int);
        };
        "unavailableReplicas" = mkOption {
          description = "Total number of unavailable pods targeted by this deployment.";
          type = (types.nullOr types.int);
        };
        "updatedReplicas" = mkOption {
          description =
            "Total number of non-terminated pods targeted by this deployment that have the desired template spec.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "availableReplicas" = mkOverride 1002 null;
        "collisionCount" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "readyReplicas" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "unavailableReplicas" = mkOverride 1002 null;
        "updatedReplicas" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description =
            "Rolling update config params. Present only if DeploymentStrategyType = RollingUpdate.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollingUpdateDeployment"));
        };
        "type" = mkOption {
          description =
            ''Type of deployment. Can be "Recreate" or "RollingUpdate". Default is RollingUpdate.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollbackConfig" = {

      options = {
        "revision" = mkOption {
          description = "The revision to rollback to. If set to 0, rollback to the last revision.";
          type = (types.nullOr types.int);
        };
      };

      config = { "revision" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollingUpdateDeployment" = {

      options = {
        "maxSurge" = mkOption {
          description =
            "The maximum number of pods that can be scheduled above the desired number of pods. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number is calculated from percentage by rounding up. Defaults to 25%. Example: when this is set to 30%, the new RC can be scaled up immediately when the rolling update starts, such that the total number of old and new pods do not exceed 130% of desired pods. Once old pods have been killed, new RC can be scaled up further, ensuring that total number of pods running at any time during the update is atmost 130% of desired pods.";
          type = (types.nullOr (types.either types.int types.str));
        };
        "maxUnavailable" = mkOption {
          description =
            "The maximum number of pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). Absolute number is calculated from percentage by rounding down. This can not be 0 if MaxSurge is 0. Defaults to 25%. Example: when this is set to 30%, the old RC can be scaled down to 70% of desired pods immediately when the rolling update starts. Once new pods are ready, old RC can be scaled down further, followed by scaling up the new RC, ensuring that the total number of pods available at all times during the update is at least 70% of desired pods.";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxSurge" = mkOverride 1002 null;
        "maxUnavailable" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollingUpdateStatefulSetStrategy" = {

      options = {
        "partition" = mkOption {
          description =
            "Partition indicates the ordinal at which the StatefulSet should be partitioned.";
          type = (types.nullOr types.int);
        };
      };

      config = { "partition" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.Scale" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ScaleSpec"));
        };
        "status" = mkOption {
          description =
            "current status of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status. Read-only.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ScaleStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ScaleSpec" = {

      options = {
        "replicas" = mkOption {
          description = "desired number of instances for the scaled object.";
          type = (types.nullOr types.int);
        };
      };

      config = { "replicas" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ScaleStatus" = {

      options = {
        "replicas" = mkOption {
          description = "actual number of observed instances of the scaled object.";
          type = types.int;
        };
        "selector" = mkOption {
          description =
            "label query over pods that should match the replicas count. More info: http://kubernetes.io/docs/user-guide/labels#label-selectors";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "targetSelector" = mkOption {
          description =
            "label selector for pods that should match the replicas count. This is a serializated version of both map-based and more expressive set-based selectors. This is done to avoid introspection in the clients. The string will be in the same format as the query-param syntax. If the target type only supports map-based selectors, both this field and map-based selector field are populated. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "selector" = mkOverride 1002 null;
        "targetSelector" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSet" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec defines the desired identities of pods in this set.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetSpec"));
        };
        "status" = mkOption {
          description =
            "Status is the current status of Pods in this StatefulSet. This data may be out of date by some window of time.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSet"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetSpec" = {

      options = {
        "podManagementPolicy" = mkOption {
          description =
            "podManagementPolicy controls how pods are created during initial scale up, when replacing pods on nodes, or when scaling down. The default policy is `OrderedReady`, where pods are created in increasing order (pod-0, then pod-1, etc) and the controller will wait until each pod is ready before continuing. When scaling down, the pods are removed in the opposite order. The alternative policy is `Parallel` which will create pods in parallel to match the desired scale without waiting, and on scale down will delete all pods at once.";
          type = (types.nullOr types.str);
        };
        "replicas" = mkOption {
          description =
            "replicas is the desired number of replicas of the given Template. These are replicas in the sense that they are instantiations of the same Template, but individual replicas also have a consistent identity. If unspecified, defaults to 1.";
          type = (types.nullOr types.int);
        };
        "revisionHistoryLimit" = mkOption {
          description =
            "revisionHistoryLimit is the maximum number of revisions that will be maintained in the StatefulSet's revision history. The revision history consists of all revisions not represented by a currently applied StatefulSetSpec version. The default value is 10.";
          type = (types.nullOr types.int);
        };
        "selector" = mkOption {
          description =
            "selector is a label query over pods that should match the replica count. If empty, defaulted to labels on the pod template. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "serviceName" = mkOption {
          description = ''
            serviceName is the name of the service that governs this StatefulSet. This service must exist before the StatefulSet, and is responsible for the network identity of the set. Pods get DNS/hostnames that follow the pattern: pod-specific-string.serviceName.default.svc.cluster.local where "pod-specific-string" is managed by the StatefulSet controller.'';
          type = types.str;
        };
        "template" = mkOption {
          description =
            "template is the object that describes the pod that will be created if insufficient replicas are detected. Each pod stamped out by the StatefulSet will fulfill this Template, but have a unique identity from the rest of the StatefulSet.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec");
        };
        "updateStrategy" = mkOption {
          description =
            "updateStrategy indicates the StatefulSetUpdateStrategy that will be employed to update Pods in the StatefulSet when a revision is made to Template.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetUpdateStrategy"));
        };
        "volumeClaimTemplates" = mkOption {
          description =
            "volumeClaimTemplates is a list of claims that pods are allowed to reference. The StatefulSet controller is responsible for mapping network identities to claims in a way that maintains the identity of a pod. Every claim in this list must have at least one matching (by name) volumeMount in one container in the template. A claim in this list takes precedence over any volumes in the template, with the same name.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaim")));
        };
      };

      config = {
        "podManagementPolicy" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "revisionHistoryLimit" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "updateStrategy" = mkOverride 1002 null;
        "volumeClaimTemplates" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetStatus" = {

      options = {
        "currentReplicas" = mkOption {
          description =
            "currentReplicas is the number of Pods created by the StatefulSet controller from the StatefulSet version indicated by currentRevision.";
          type = (types.nullOr types.int);
        };
        "currentRevision" = mkOption {
          description =
            "currentRevision, if not empty, indicates the version of the StatefulSet used to generate Pods in the sequence [0,currentReplicas).";
          type = (types.nullOr types.str);
        };
        "observedGeneration" = mkOption {
          description =
            "observedGeneration is the most recent generation observed for this StatefulSet. It corresponds to the StatefulSet's generation, which is updated on mutation by the API Server.";
          type = (types.nullOr types.int);
        };
        "readyReplicas" = mkOption {
          description =
            "readyReplicas is the number of Pods created by the StatefulSet controller that have a Ready Condition.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description = "replicas is the number of Pods created by the StatefulSet controller.";
          type = types.int;
        };
        "updateRevision" = mkOption {
          description =
            "updateRevision, if not empty, indicates the version of the StatefulSet used to generate Pods in the sequence [replicas-updatedReplicas,replicas)";
          type = (types.nullOr types.str);
        };
        "updatedReplicas" = mkOption {
          description =
            "updatedReplicas is the number of Pods created by the StatefulSet controller from the StatefulSet version indicated by updateRevision.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "currentReplicas" = mkOverride 1002 null;
        "currentRevision" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "readyReplicas" = mkOverride 1002 null;
        "updateRevision" = mkOverride 1002 null;
        "updatedReplicas" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSetUpdateStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description =
            "RollingUpdate is used to communicate parameters when Type is RollingUpdateStatefulSetStrategyType.";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.apps.v1beta1.RollingUpdateStatefulSetStrategy"));
        };
        "type" = mkOption {
          description = "Type indicates the type of the StatefulSetUpdateStrategy.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec holds information about the request being evaluated";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request can be authenticated.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReviewSpec" = {

      options = {
        "token" = mkOption {
          description = "Token is the opaque bearer token.";
          type = (types.nullOr types.str);
        };
      };

      config = { "token" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReviewStatus" = {

      options = {
        "authenticated" = mkOption {
          description = "Authenticated indicates that the token was associated with a known user.";
          type = (types.nullOr types.bool);
        };
        "error" = mkOption {
          description = "Error indicates that the token couldn't be checked";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "User is the UserInfo associated with the provided token.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.authentication.v1.UserInfo"));
        };
      };

      config = {
        "authenticated" = mkOverride 1002 null;
        "error" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1.UserInfo" = {

      options = {
        "extra" = mkOption {
          description = "Any additional information provided by the authenticator.";
          type = (types.nullOr (types.loaOf types.str));
        };
        "groups" = mkOption {
          description = "The names of groups this user is a part of.";
          type = (types.nullOr (types.listOf types.str));
        };
        "uid" = mkOption {
          description =
            "A unique value that identifies this user across time. If this user is deleted and another user by the same name is added, they will have different UIDs.";
          type = (types.nullOr types.str);
        };
        "username" = mkOption {
          description = "The name that uniquely identifies this user among all active users.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "extra" = mkOverride 1002 null;
        "groups" = mkOverride 1002 null;
        "uid" = mkOverride 1002 null;
        "username" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.TokenReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec holds information about the request being evaluated";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.TokenReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request can be authenticated.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.TokenReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.TokenReviewSpec" = {

      options = {
        "token" = mkOption {
          description = "Token is the opaque bearer token.";
          type = (types.nullOr types.str);
        };
      };

      config = { "token" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.TokenReviewStatus" = {

      options = {
        "authenticated" = mkOption {
          description = "Authenticated indicates that the token was associated with a known user.";
          type = (types.nullOr types.bool);
        };
        "error" = mkOption {
          description = "Error indicates that the token couldn't be checked";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "User is the UserInfo associated with the provided token.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.UserInfo"));
        };
      };

      config = {
        "authenticated" = mkOverride 1002 null;
        "error" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.UserInfo" = {

      options = {
        "extra" = mkOption {
          description = "Any additional information provided by the authenticator.";
          type = (types.nullOr (types.loaOf types.str));
        };
        "groups" = mkOption {
          description = "The names of groups this user is a part of.";
          type = (types.nullOr (types.listOf types.str));
        };
        "uid" = mkOption {
          description =
            "A unique value that identifies this user across time. If this user is deleted and another user by the same name is added, they will have different UIDs.";
          type = (types.nullOr types.str);
        };
        "username" = mkOption {
          description = "The name that uniquely identifies this user among all active users.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "extra" = mkOverride 1002 null;
        "groups" = mkOverride 1002 null;
        "uid" = mkOverride 1002 null;
        "username" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.LocalSubjectAccessReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec holds information about the request being evaluated.  spec.namespace must be equal to the namespace you made the request against.  If empty, it is defaulted.";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request is allowed or not";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.NonResourceAttributes" = {

      options = {
        "path" = mkOption {
          description = "Path is the URL path of the request";
          type = (types.nullOr types.str);
        };
        "verb" = mkOption {
          description = "Verb is the standard HTTP verb";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "verb" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.ResourceAttributes" = {

      options = {
        "group" = mkOption {
          description = ''Group is the API Group of the Resource.  "*" means all.'';
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = ''
            Name is the name of the resource being requested for a "get" or deleted for a "delete". "" (empty) means all.'';
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = ''
            Namespace is the namespace of the action being requested.  Currently, there is no distinction between no namespace and all namespaces "" (empty) is defaulted for LocalSubjectAccessReviews "" (empty) is empty for cluster-scoped resources "" (empty) means "all" for namespace scoped resources from a SubjectAccessReview or SelfSubjectAccessReview'';
          type = (types.nullOr types.str);
        };
        "resource" = mkOption {
          description = ''Resource is one of the existing resource types.  "*" means all.'';
          type = (types.nullOr types.str);
        };
        "subresource" = mkOption {
          description = ''Subresource is one of the existing resource types.  "" means none.'';
          type = (types.nullOr types.str);
        };
        "verb" = mkOption {
          description = ''
            Verb is a kubernetes resource API verb, like: get, list, watch, create, update, delete, proxy.  "*" means all.'';
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = ''Version is the API Version of the Resource.  "*" means all.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "resource" = mkOverride 1002 null;
        "subresource" = mkOverride 1002 null;
        "verb" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.SelfSubjectAccessReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec holds information about the request being evaluated.  user and groups must be empty";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.SelfSubjectAccessReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request is allowed or not";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.SelfSubjectAccessReviewSpec" = {

      options = {
        "nonResourceAttributes" = mkOption {
          description =
            "NonResourceAttributes describes information for a non-resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.NonResourceAttributes"));
        };
        "resourceAttributes" = mkOption {
          description =
            "ResourceAuthorizationAttributes describes information for a resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.ResourceAttributes"));
        };
      };

      config = {
        "nonResourceAttributes" = mkOverride 1002 null;
        "resourceAttributes" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec holds information about the request being evaluated";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request is allowed or not";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewSpec" = {

      options = {
        "extra" = mkOption {
          description =
            "Extra corresponds to the user.Info.GetExtra() method from the authenticator.  Since that is input to the authorizer it needs a reflection here.";
          type = (types.nullOr (types.loaOf types.str));
        };
        "groups" = mkOption {
          description = "Groups is the groups you're testing for.";
          type = (types.nullOr (types.listOf types.str));
        };
        "nonResourceAttributes" = mkOption {
          description =
            "NonResourceAttributes describes information for a non-resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.NonResourceAttributes"));
        };
        "resourceAttributes" = mkOption {
          description =
            "ResourceAuthorizationAttributes describes information for a resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1.ResourceAttributes"));
        };
        "user" = mkOption {
          description = ''
            User is the user you're testing for. If you specify "User" but not "Groups", then is it interpreted as "What if User were not a member of any groups'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "extra" = mkOverride 1002 null;
        "groups" = mkOverride 1002 null;
        "nonResourceAttributes" = mkOverride 1002 null;
        "resourceAttributes" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReviewStatus" = {

      options = {
        "allowed" = mkOption {
          description =
            "Allowed is required.  True if the action would be allowed, false otherwise.";
          type = types.bool;
        };
        "evaluationError" = mkOption {
          description =
            "EvaluationError is an indication that some error occurred during the authorization check. It is entirely possible to get an error and be able to continue determine authorization status in spite of it. For instance, RBAC can be missing a role, but enough roles are still present and bound to reason about the request.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "Reason is optional.  It indicates why a request was allowed or denied.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "evaluationError" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.LocalSubjectAccessReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec holds information about the request being evaluated.  spec.namespace must be equal to the namespace you made the request against.  If empty, it is defaulted.";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request is allowed or not";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.NonResourceAttributes" = {

      options = {
        "path" = mkOption {
          description = "Path is the URL path of the request";
          type = (types.nullOr types.str);
        };
        "verb" = mkOption {
          description = "Verb is the standard HTTP verb";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "verb" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.ResourceAttributes" = {

      options = {
        "group" = mkOption {
          description = ''Group is the API Group of the Resource.  "*" means all.'';
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = ''
            Name is the name of the resource being requested for a "get" or deleted for a "delete". "" (empty) means all.'';
          type = (types.nullOr types.str);
        };
        "namespace" = mkOption {
          description = ''
            Namespace is the namespace of the action being requested.  Currently, there is no distinction between no namespace and all namespaces "" (empty) is defaulted for LocalSubjectAccessReviews "" (empty) is empty for cluster-scoped resources "" (empty) means "all" for namespace scoped resources from a SubjectAccessReview or SelfSubjectAccessReview'';
          type = (types.nullOr types.str);
        };
        "resource" = mkOption {
          description = ''Resource is one of the existing resource types.  "*" means all.'';
          type = (types.nullOr types.str);
        };
        "subresource" = mkOption {
          description = ''Subresource is one of the existing resource types.  "" means none.'';
          type = (types.nullOr types.str);
        };
        "verb" = mkOption {
          description = ''
            Verb is a kubernetes resource API verb, like: get, list, watch, create, update, delete, proxy.  "*" means all.'';
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = ''Version is the API Version of the Resource.  "*" means all.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "resource" = mkOverride 1002 null;
        "subresource" = mkOverride 1002 null;
        "verb" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SelfSubjectAccessReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec holds information about the request being evaluated.  user and groups must be empty";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SelfSubjectAccessReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request is allowed or not";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SelfSubjectAccessReviewSpec" = {

      options = {
        "nonResourceAttributes" = mkOption {
          description =
            "NonResourceAttributes describes information for a non-resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.NonResourceAttributes"));
        };
        "resourceAttributes" = mkOption {
          description =
            "ResourceAuthorizationAttributes describes information for a resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.ResourceAttributes"));
        };
      };

      config = {
        "nonResourceAttributes" = mkOverride 1002 null;
        "resourceAttributes" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReview" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Spec holds information about the request being evaluated";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewSpec");
        };
        "status" = mkOption {
          description =
            "Status is filled in by the server and indicates whether the request is allowed or not";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewSpec" = {

      options = {
        "extra" = mkOption {
          description =
            "Extra corresponds to the user.Info.GetExtra() method from the authenticator.  Since that is input to the authorizer it needs a reflection here.";
          type = (types.nullOr (types.loaOf types.str));
        };
        "group" = mkOption {
          description = "Groups is the groups you're testing for.";
          type = (types.nullOr (types.listOf types.str));
        };
        "nonResourceAttributes" = mkOption {
          description =
            "NonResourceAttributes describes information for a non-resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.NonResourceAttributes"));
        };
        "resourceAttributes" = mkOption {
          description =
            "ResourceAuthorizationAttributes describes information for a resource access request";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.ResourceAttributes"));
        };
        "user" = mkOption {
          description = ''
            User is the user you're testing for. If you specify "User" but not "Group", then is it interpreted as "What if User were not a member of any groups'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "extra" = mkOverride 1002 null;
        "group" = mkOverride 1002 null;
        "nonResourceAttributes" = mkOverride 1002 null;
        "resourceAttributes" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReviewStatus" = {

      options = {
        "allowed" = mkOption {
          description =
            "Allowed is required.  True if the action would be allowed, false otherwise.";
          type = types.bool;
        };
        "evaluationError" = mkOption {
          description =
            "EvaluationError is an indication that some error occurred during the authorization check. It is entirely possible to get an error and be able to continue determine authorization status in spite of it. For instance, RBAC can be missing a role, but enough roles are still present and bound to reason about the request.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "Reason is optional.  It indicates why a request was allowed or denied.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "evaluationError" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.CrossVersionObjectReference" = {

      options = {
        "apiVersion" = mkOption {
          description = "API version of the referent";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = ''
            Kind of the referent; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds"'';
          type = types.str;
        };
        "name" = mkOption {
          description =
            "Name of the referent; More info: http://kubernetes.io/docs/user-guide/identifiers#names";
          type = types.str;
        };
      };

      config = { "apiVersion" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscaler" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "behaviour of autoscaler. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscalerSpec"));
        };
        "status" = mkOption {
          description = "current information about the autoscaler.";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscalerStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscalerList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "list of horizontal pod autoscaler objects.";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscaler"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard list metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscalerSpec" = {

      options = {
        "maxReplicas" = mkOption {
          description =
            "upper limit for the number of pods that can be set by the autoscaler; cannot be smaller than MinReplicas.";
          type = types.int;
        };
        "minReplicas" = mkOption {
          description =
            "lower limit for the number of pods that can be set by the autoscaler, default 1.";
          type = (types.nullOr types.int);
        };
        "scaleTargetRef" = mkOption {
          description =
            "reference to scaled resource; horizontal pod autoscaler will learn the current resource consumption and will set the desired number of pods by using its Scale subresource.";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v1.CrossVersionObjectReference");
        };
        "targetCPUUtilizationPercentage" = mkOption {
          description =
            "target average CPU utilization (represented as a percentage of requested CPU) over all the pods; if not specified the default autoscaling policy will be used.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "minReplicas" = mkOverride 1002 null;
        "targetCPUUtilizationPercentage" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscalerStatus" = {

      options = {
        "currentCPUUtilizationPercentage" = mkOption {
          description =
            "current average CPU utilization over all pods, represented as a percentage of requested CPU, e.g. 70 means that an average pod is using now 70% of its requested CPU.";
          type = (types.nullOr types.int);
        };
        "currentReplicas" = mkOption {
          description = "current number of replicas of pods managed by this autoscaler.";
          type = types.int;
        };
        "desiredReplicas" = mkOption {
          description = "desired number of replicas of pods managed by this autoscaler.";
          type = types.int;
        };
        "lastScaleTime" = mkOption {
          description =
            "last time the HorizontalPodAutoscaler scaled the number of pods; used by the autoscaler to control how often the number of pods is changed.";
          type = (types.nullOr types.str);
        };
        "observedGeneration" = mkOption {
          description = "most recent generation observed by this autoscaler.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "currentCPUUtilizationPercentage" = mkOverride 1002 null;
        "lastScaleTime" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.Scale" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v1.ScaleSpec"));
        };
        "status" = mkOption {
          description =
            "current status of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status. Read-only.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v1.ScaleStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.ScaleSpec" = {

      options = {
        "replicas" = mkOption {
          description = "desired number of instances for the scaled object.";
          type = (types.nullOr types.int);
        };
      };

      config = { "replicas" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v1.ScaleStatus" = {

      options = {
        "replicas" = mkOption {
          description = "actual number of observed instances of the scaled object.";
          type = types.int;
        };
        "selector" = mkOption {
          description =
            "label query over pods that should match the replicas count. This is same as the label selector but in the string format to avoid introspection by clients. The string will be in the same format as the query-param syntax. More info about label selectors: http://kubernetes.io/docs/user-guide/labels#label-selectors";
          type = (types.nullOr types.str);
        };
      };

      config = { "selector" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.CrossVersionObjectReference" = {

      options = {
        "apiVersion" = mkOption {
          description = "API version of the referent";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = ''
            Kind of the referent; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds"'';
          type = types.str;
        };
        "name" = mkOption {
          description =
            "Name of the referent; More info: http://kubernetes.io/docs/user-guide/identifiers#names";
          type = types.str;
        };
      };

      config = { "apiVersion" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscaler" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "metadata is the standard object metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "spec is the specification for the behaviour of the autoscaler. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerSpec"));
        };
        "status" = mkOption {
          description = "status is the current information about the autoscaler.";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerCondition" = {

      options = {
        "lastTransitionTime" = mkOption {
          description =
            "lastTransitionTime is the last time the condition transitioned from one status to another";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description =
            "message is a human-readable explanation containing details about the transition";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "reason is the reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "status is the status of the condition (True, False, Unknown)";
          type = types.str;
        };
        "type" = mkOption {
          description = "type describes the current condition";
          type = types.str;
        };
      };

      config = {
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "items is the list of horizontal pod autoscaler objects.";
          type = (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscaler"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "metadata is the standard list metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerSpec" = {

      options = {
        "maxReplicas" = mkOption {
          description =
            "maxReplicas is the upper limit for the number of replicas to which the autoscaler can scale up. It cannot be less that minReplicas.";
          type = types.int;
        };
        "metrics" = mkOption {
          description =
            "metrics contains the specifications for which to use to calculate the desired replica count (the maximum replica count across all metrics will be used).  The desired replica count is calculated multiplying the ratio between the target value and the current value by the current number of pods.  Ergo, metrics used must decrease as the pod count is increased, and vice-versa.  See the individual metric source types for more information about how each type of metric must respond.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.MetricSpec")));
        };
        "minReplicas" = mkOption {
          description =
            "minReplicas is the lower limit for the number of replicas to which the autoscaler can scale down. It defaults to 1 pod.";
          type = (types.nullOr types.int);
        };
        "scaleTargetRef" = mkOption {
          description =
            "scaleTargetRef points to the target resource to scale, and is used to the pods for which metrics should be collected, as well as to actually change the replica count.";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.CrossVersionObjectReference");
        };
      };

      config = {
        "metrics" = mkOverride 1002 null;
        "minReplicas" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerStatus" = {

      options = {
        "conditions" = mkOption {
          description =
            "conditions is the set of conditions required for this autoscaler to scale its target, and indicates whether or not those conditions are met.";
          type = (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscalerCondition"));
        };
        "currentMetrics" = mkOption {
          description =
            "currentMetrics is the last read state of the metrics used by this autoscaler.";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.MetricStatus"));
        };
        "currentReplicas" = mkOption {
          description =
            "currentReplicas is current number of replicas of pods managed by this autoscaler, as last seen by the autoscaler.";
          type = types.int;
        };
        "desiredReplicas" = mkOption {
          description =
            "desiredReplicas is the desired number of replicas of pods managed by this autoscaler, as last calculated by the autoscaler.";
          type = types.int;
        };
        "lastScaleTime" = mkOption {
          description =
            "lastScaleTime is the last time the HorizontalPodAutoscaler scaled the number of pods, used by the autoscaler to control how often the number of pods is changed.";
          type = (types.nullOr types.str);
        };
        "observedGeneration" = mkOption {
          description =
            "observedGeneration is the most recent generation observed by this autoscaler.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "lastScaleTime" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.MetricSpec" = {

      options = {
        "object" = mkOption {
          description =
            "object refers to a metric describing a single kubernetes object (for example, hits-per-second on an Ingress object).";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ObjectMetricSource"));
        };
        "pods" = mkOption {
          description =
            "pods refers to a metric describing each pod in the current scale target (for example, transactions-processed-per-second).  The values will be averaged together before being compared to the target value.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.PodsMetricSource"));
        };
        "resource" = mkOption {
          description = ''
            resource refers to a resource metric (such as those specified in requests and limits) known to Kubernetes describing each pod in the current scale target (e.g. CPU or memory). Such metrics are built in to Kubernetes, and have special scaling options on top of those available to normal per-pod metrics using the "pods" source.'';
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ResourceMetricSource"));
        };
        "type" = mkOption {
          description =
            "type is the type of metric source.  It should match one of the fields below.";
          type = types.str;
        };
      };

      config = {
        "object" = mkOverride 1002 null;
        "pods" = mkOverride 1002 null;
        "resource" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.MetricStatus" = {

      options = {
        "object" = mkOption {
          description =
            "object refers to a metric describing a single kubernetes object (for example, hits-per-second on an Ingress object).";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ObjectMetricStatus"));
        };
        "pods" = mkOption {
          description =
            "pods refers to a metric describing each pod in the current scale target (for example, transactions-processed-per-second).  The values will be averaged together before being compared to the target value.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.PodsMetricStatus"));
        };
        "resource" = mkOption {
          description = ''
            resource refers to a resource metric (such as those specified in requests and limits) known to Kubernetes describing each pod in the current scale target (e.g. CPU or memory). Such metrics are built in to Kubernetes, and have special scaling options on top of those available to normal per-pod metrics using the "pods" source.'';
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ResourceMetricStatus"));
        };
        "type" = mkOption {
          description =
            "type is the type of metric source.  It will match one of the fields below.";
          type = types.str;
        };
      };

      config = {
        "object" = mkOverride 1002 null;
        "pods" = mkOverride 1002 null;
        "resource" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ObjectMetricSource" = {

      options = {
        "metricName" = mkOption {
          description = "metricName is the name of the metric in question.";
          type = types.str;
        };
        "target" = mkOption {
          description = "target is the described Kubernetes object.";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.CrossVersionObjectReference");
        };
        "targetValue" = mkOption {
          description = "targetValue is the target value of the metric (as a quantity).";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ObjectMetricStatus" = {

      options = {
        "currentValue" = mkOption {
          description = "currentValue is the current value of the metric (as a quantity).";
          type = types.str;
        };
        "metricName" = mkOption {
          description = "metricName is the name of the metric in question.";
          type = types.str;
        };
        "target" = mkOption {
          description = "target is the described Kubernetes object.";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.CrossVersionObjectReference");
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.PodsMetricSource" = {

      options = {
        "metricName" = mkOption {
          description = "metricName is the name of the metric in question";
          type = types.str;
        };
        "targetAverageValue" = mkOption {
          description =
            "targetAverageValue is the target value of the average of the metric across all relevant pods (as a quantity)";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.PodsMetricStatus" = {

      options = {
        "currentAverageValue" = mkOption {
          description =
            "currentAverageValue is the current value of the average of the metric across all relevant pods (as a quantity)";
          type = types.str;
        };
        "metricName" = mkOption {
          description = "metricName is the name of the metric in question";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ResourceMetricSource" = {

      options = {
        "name" = mkOption {
          description = "name is the name of the resource in question.";
          type = types.str;
        };
        "targetAverageUtilization" = mkOption {
          description =
            "targetAverageUtilization is the target value of the average of the resource metric across all relevant pods, represented as a percentage of the requested value of the resource for the pods.";
          type = (types.nullOr types.int);
        };
        "targetAverageValue" = mkOption {
          description = ''
            targetAverageValue is the target value of the average of the resource metric across all relevant pods, as a raw value (instead of as a percentage of the request), similar to the "pods" metric source type.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "targetAverageUtilization" = mkOverride 1002 null;
        "targetAverageValue" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.ResourceMetricStatus" = {

      options = {
        "currentAverageUtilization" = mkOption {
          description =
            "currentAverageUtilization is the current value of the average of the resource metric across all relevant pods, represented as a percentage of the requested value of the resource for the pods.  It will only be present if `targetAverageValue` was set in the corresponding metric specification.";
          type = (types.nullOr types.int);
        };
        "currentAverageValue" = mkOption {
          description = ''
            currentAverageValue is the current value of the average of the resource metric across all relevant pods, as a raw value (instead of as a percentage of the request), similar to the "pods" metric source type. It will always be set, regardless of the corresponding metric specification.'';
          type = types.str;
        };
        "name" = mkOption {
          description = "name is the name of the resource in question.";
          type = types.str;
        };
      };

      config = { "currentAverageUtilization" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v1.Job" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Specification of the desired behavior of a job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v1.JobSpec"));
        };
        "status" = mkOption {
          description =
            "Current status of a job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v1.JobStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v1.JobCondition" = {

      options = {
        "lastProbeTime" = mkOption {
          description = "Last time the condition was checked.";
          type = (types.nullOr types.str);
        };
        "lastTransitionTime" = mkOption {
          description = "Last time the condition transit from one status to another.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "Human readable message indicating details about last transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "(brief) reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type of job condition, Complete or Failed.";
          type = types.str;
        };
      };

      config = {
        "lastProbeTime" = mkOverride 1002 null;
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v1.JobList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "items is the list of Jobs.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v1.Job"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v1.JobSpec" = {

      options = {
        "activeDeadlineSeconds" = mkOption {
          description =
            "Optional duration in seconds relative to the startTime that the job may be active before the system tries to terminate it; value must be positive integer";
          type = (types.nullOr types.int);
        };
        "completions" = mkOption {
          description =
            "Specifies the desired number of successfully finished pods the job should be run with.  Setting to nil means that the success of any pod signals the success of all pods, and allows parallelism to have any positive value.  Setting to 1 means that parallelism is limited to 1 and the success of that pod signals the success of the job. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/";
          type = (types.nullOr types.int);
        };
        "manualSelector" = mkOption {
          description =
            "manualSelector controls generation of pod labels and pod selectors. Leave `manualSelector` unset unless you are certain what you are doing. When false or unset, the system pick labels unique to this job and appends those labels to the pod template.  When true, the user is responsible for picking unique labels and specifying the selector.  Failure to pick a unique label may cause this and other jobs to not function correctly.  However, You may see `manualSelector=true` in jobs that were created with the old `extensions/v1beta1` API. More info: https://git.k8s.io/community/contributors/design-proposals/selector-generation.md";
          type = (types.nullOr types.bool);
        };
        "parallelism" = mkOption {
          description =
            "Specifies the maximum desired number of pods the job should run at any given time. The actual number of pods running in steady state will be less than this number when ((.spec.completions - .status.successful) u003c .spec.parallelism), i.e. when the work left to do is less than max parallelism. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/";
          type = (types.nullOr types.int);
        };
        "selector" = mkOption {
          description =
            "A label query over pods that should match the pod count. Normally, the system sets this field for you. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "template" = mkOption {
          description =
            "Describes the pod that will be created when executing a job. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec");
        };
      };

      config = {
        "activeDeadlineSeconds" = mkOverride 1002 null;
        "completions" = mkOverride 1002 null;
        "manualSelector" = mkOverride 1002 null;
        "parallelism" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v1.JobStatus" = {

      options = {
        "active" = mkOption {
          description = "The number of actively running pods.";
          type = (types.nullOr types.int);
        };
        "completionTime" = mkOption {
          description =
            "Represents time when the job was completed. It is not guaranteed to be set in happens-before order across separate operations. It is represented in RFC3339 form and is in UTC.";
          type = (types.nullOr types.str);
        };
        "conditions" = mkOption {
          description =
            "The latest available observations of an object's current state. More info: https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/";
          type = (types.nullOr
            (coerceAttrsOfSubmodulesToListByKey "io.k8s.kubernetes.pkg.apis.batch.v1.JobCondition"
              "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "failed" = mkOption {
          description = "The number of pods which reached phase Failed.";
          type = (types.nullOr types.int);
        };
        "startTime" = mkOption {
          description =
            "Represents time when the job was acknowledged by the job controller. It is not guaranteed to be set in happens-before order across separate operations. It is represented in RFC3339 form and is in UTC.";
          type = (types.nullOr types.str);
        };
        "succeeded" = mkOption {
          description = "The number of pods which reached phase Succeeded.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "active" = mkOverride 1002 null;
        "completionTime" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "failed" = mkOverride 1002 null;
        "startTime" = mkOverride 1002 null;
        "succeeded" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJob" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Specification of the desired behavior of a cron job, including the schedule. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJobSpec"));
        };
        "status" = mkOption {
          description =
            "Current status of a cron job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJobStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJobList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "items is the list of CronJobs.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJob"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJobSpec" = {

      options = {
        "concurrencyPolicy" = mkOption {
          description = "Specifies how to treat concurrent executions of a Job. Defaults to Allow.";
          type = (types.nullOr types.str);
        };
        "failedJobsHistoryLimit" = mkOption {
          description =
            "The number of failed finished jobs to retain. This is a pointer to distinguish between explicit zero and not specified.";
          type = (types.nullOr types.int);
        };
        "jobTemplate" = mkOption {
          description = "Specifies the job that will be created when executing a CronJob.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.JobTemplateSpec");
        };
        "schedule" = mkOption {
          description = "The schedule in Cron format, see https://en.wikipedia.org/wiki/Cron.";
          type = types.str;
        };
        "startingDeadlineSeconds" = mkOption {
          description =
            "Optional deadline in seconds for starting the job if it misses scheduled time for any reason.  Missed jobs executions will be counted as failed ones.";
          type = (types.nullOr types.int);
        };
        "successfulJobsHistoryLimit" = mkOption {
          description =
            "The number of successful finished jobs to retain. This is a pointer to distinguish between explicit zero and not specified.";
          type = (types.nullOr types.int);
        };
        "suspend" = mkOption {
          description =
            "This flag tells the controller to suspend subsequent executions, it does not apply to already started executions.  Defaults to false.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "concurrencyPolicy" = mkOverride 1002 null;
        "failedJobsHistoryLimit" = mkOverride 1002 null;
        "startingDeadlineSeconds" = mkOverride 1002 null;
        "successfulJobsHistoryLimit" = mkOverride 1002 null;
        "suspend" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJobStatus" = {

      options = {
        "active" = mkOption {
          description = "A list of pointers to currently running jobs.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.ObjectReference")));
        };
        "lastScheduleTime" = mkOption {
          description = "Information when was the last time the job was successfully scheduled.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "active" = mkOverride 1002 null;
        "lastScheduleTime" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.JobTemplateSpec" = {

      options = {
        "metadata" = mkOption {
          description =
            "Standard object's metadata of the jobs created from this template. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Specification of the desired behavior of the job. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.batch.v1.JobSpec"));
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequest" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "The certificate request itself and any additional information.";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestSpec"));
        };
        "status" = mkOption {
          description = "Derived information about the request.";
          type = (types.nullOr (submoduleOf
            "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestCondition" = {

      options = {
        "lastUpdateTime" = mkOption {
          description = "timestamp for the last update to this condition";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "human readable message with details about the request state";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "brief reason for the request state";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "request approval state, currently Approved or Denied.";
          type = types.str;
        };
      };

      config = {
        "lastUpdateTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "";
          type = (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequest"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestSpec" = {

      options = {
        "extra" = mkOption {
          description =
            "Extra information about the requesting user. See user.Info interface for details.";
          type = (types.nullOr (types.loaOf types.str));
        };
        "groups" = mkOption {
          description =
            "Group information about the requesting user. See user.Info interface for details.";
          type = (types.nullOr (types.listOf types.str));
        };
        "request" = mkOption {
          description = "Base64-encoded PKCS#10 CSR data";
          type = types.str;
        };
        "uid" = mkOption {
          description =
            "UID information about the requesting user. See user.Info interface for details.";
          type = (types.nullOr types.str);
        };
        "usages" = mkOption {
          description = ''
            allowedUsages specifies a set of usage contexts the key will be valid for. See: https://tools.ietf.org/html/rfc5280#section-4.2.1.3
                 https://tools.ietf.org/html/rfc5280#section-4.2.1.12'';
          type = (types.nullOr (types.listOf types.str));
        };
        "username" = mkOption {
          description =
            "Information about the requesting user. See user.Info interface for details.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "extra" = mkOverride 1002 null;
        "groups" = mkOverride 1002 null;
        "uid" = mkOverride 1002 null;
        "usages" = mkOverride 1002 null;
        "username" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestStatus" = {

      options = {
        "certificate" = mkOption {
          description =
            "If request was approved, the controller will place the issued certificate here.";
          type = (types.nullOr types.str);
        };
        "conditions" = mkOption {
          description = "Conditions applied to the request, such as approval or denial.";
          type = (types.nullOr (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequestCondition")));
        };
      };

      config = {
        "certificate" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.APIVersion" = {

      options = {
        "name" = mkOption {
          description = "Name of this version (e.g. 'v1').";
          type = (types.nullOr types.str);
        };
      };

      config = { "name" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSet" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "The desired behavior of this daemon set. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetSpec"));
        };
        "status" = mkOption {
          description =
            "The current status of this daemon set. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "A list of daemon sets.";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSet"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetSpec" = {

      options = {
        "minReadySeconds" = mkOption {
          description =
            "The minimum number of seconds for which a newly created DaemonSet pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready).";
          type = (types.nullOr types.int);
        };
        "revisionHistoryLimit" = mkOption {
          description =
            "The number of old history to retain to allow rollback. This is a pointer to distinguish between explicit zero and not specified. Defaults to 10.";
          type = (types.nullOr types.int);
        };
        "selector" = mkOption {
          description =
            "A label query over pods that are managed by the daemon set. Must match in order to be controlled. If empty, defaulted to labels on Pod template. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "template" = mkOption {
          description =
            "An object that describes the pod that will be created. The DaemonSet will create exactly one copy of this pod on every node that matches the template's node selector (or on every node if no node selector is specified). More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec");
        };
        "templateGeneration" = mkOption {
          description =
            "DEPRECATED. A sequence number representing a specific generation of the template. Populated by the system. It can be set only during the creation.";
          type = (types.nullOr types.int);
        };
        "updateStrategy" = mkOption {
          description = "An update strategy to replace existing DaemonSet pods with new pods.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetUpdateStrategy"));
        };
      };

      config = {
        "minReadySeconds" = mkOverride 1002 null;
        "revisionHistoryLimit" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "templateGeneration" = mkOverride 1002 null;
        "updateStrategy" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetStatus" = {

      options = {
        "collisionCount" = mkOption {
          description =
            "Count of hash collisions for the DaemonSet. The DaemonSet controller uses this field as a collision avoidance mechanism when it needs to create the name for the newest ControllerRevision.";
          type = (types.nullOr types.int);
        };
        "currentNumberScheduled" = mkOption {
          description =
            "The number of nodes that are running at least 1 daemon pod and are supposed to run the daemon pod. More info: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/";
          type = types.int;
        };
        "desiredNumberScheduled" = mkOption {
          description =
            "The total number of nodes that should be running the daemon pod (including nodes correctly running the daemon pod). More info: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/";
          type = types.int;
        };
        "numberAvailable" = mkOption {
          description =
            "The number of nodes that should be running the daemon pod and have one or more of the daemon pod running and available (ready for at least spec.minReadySeconds)";
          type = (types.nullOr types.int);
        };
        "numberMisscheduled" = mkOption {
          description =
            "The number of nodes that are running the daemon pod, but are not supposed to run the daemon pod. More info: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/";
          type = types.int;
        };
        "numberReady" = mkOption {
          description =
            "The number of nodes that should be running the daemon pod and have one or more of the daemon pod running and ready.";
          type = types.int;
        };
        "numberUnavailable" = mkOption {
          description =
            "The number of nodes that should be running the daemon pod and have none of the daemon pod running and available (ready for at least spec.minReadySeconds)";
          type = (types.nullOr types.int);
        };
        "observedGeneration" = mkOption {
          description = "The most recent generation observed by the daemon set controller.";
          type = (types.nullOr types.int);
        };
        "updatedNumberScheduled" = mkOption {
          description = "The total number of nodes that are running updated daemon pod";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "collisionCount" = mkOverride 1002 null;
        "numberAvailable" = mkOverride 1002 null;
        "numberUnavailable" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "updatedNumberScheduled" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSetUpdateStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description = ''Rolling update config params. Present only if type = "RollingUpdate".'';
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollingUpdateDaemonSet"));
        };
        "type" = mkOption {
          description = ''
            Type of daemon set update. Can be "RollingUpdate" or "OnDelete". Default is OnDelete.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Deployment" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the Deployment.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentSpec"));
        };
        "status" = mkOption {
          description = "Most recently observed status of the Deployment.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentCondition" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "Last time the condition transitioned from one status to another.";
          type = (types.nullOr types.str);
        };
        "lastUpdateTime" = mkOption {
          description = "The last time this condition was updated.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "A human readable message indicating details about the transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "The reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type of deployment condition.";
          type = types.str;
        };
      };

      config = {
        "lastTransitionTime" = mkOverride 1002 null;
        "lastUpdateTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of Deployments.";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Deployment"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard list metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentRollback" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Required: This must match the Name of a deployment.";
          type = types.str;
        };
        "rollbackTo" = mkOption {
          description = "The config of this deployment rollback.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollbackConfig");
        };
        "updatedAnnotations" = mkOption {
          description = "The annotations to be updated to a deployment";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "updatedAnnotations" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentSpec" = {

      options = {
        "minReadySeconds" = mkOption {
          description =
            "Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)";
          type = (types.nullOr types.int);
        };
        "paused" = mkOption {
          description =
            "Indicates that the deployment is paused and will not be processed by the deployment controller.";
          type = (types.nullOr types.bool);
        };
        "progressDeadlineSeconds" = mkOption {
          description =
            "The maximum time in seconds for a deployment to make progress before it is considered to be failed. The deployment controller will continue to process failed deployments and a condition with a ProgressDeadlineExceeded reason will be surfaced in the deployment status. Once autoRollback is implemented, the deployment controller will automatically rollback failed deployments. Note that progress will not be estimated during the time a deployment is paused. This is not set by default.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Number of desired pods. This is a pointer to distinguish between explicit zero and not specified. Defaults to 1.";
          type = (types.nullOr types.int);
        };
        "revisionHistoryLimit" = mkOption {
          description =
            "The number of old ReplicaSets to retain to allow rollback. This is a pointer to distinguish between explicit zero and not specified.";
          type = (types.nullOr types.int);
        };
        "rollbackTo" = mkOption {
          description =
            "The config this deployment is rolling back to. Will be cleared after rollback is done.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollbackConfig"));
        };
        "selector" = mkOption {
          description =
            "Label selector for pods. Existing ReplicaSets whose pods are selected by this will be the ones affected by this deployment.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "strategy" = mkOption {
          description = "The deployment strategy to use to replace existing pods with new ones.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentStrategy"));
        };
        "template" = mkOption {
          description = "Template describes the pods that will be created.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec");
        };
      };

      config = {
        "minReadySeconds" = mkOverride 1002 null;
        "paused" = mkOverride 1002 null;
        "progressDeadlineSeconds" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "revisionHistoryLimit" = mkOverride 1002 null;
        "rollbackTo" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "strategy" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentStatus" = {

      options = {
        "availableReplicas" = mkOption {
          description =
            "Total number of available pods (ready for at least minReadySeconds) targeted by this deployment.";
          type = (types.nullOr types.int);
        };
        "collisionCount" = mkOption {
          description =
            "Count of hash collisions for the Deployment. The Deployment controller uses this field as a collision avoidance mechanism when it needs to create the name for the newest ReplicaSet.";
          type = (types.nullOr types.int);
        };
        "conditions" = mkOption {
          description =
            "Represents the latest available observations of a deployment's current state.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentCondition" "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "observedGeneration" = mkOption {
          description = "The generation observed by the deployment controller.";
          type = (types.nullOr types.int);
        };
        "readyReplicas" = mkOption {
          description = "Total number of ready pods targeted by this deployment.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Total number of non-terminated pods targeted by this deployment (their labels match the selector).";
          type = (types.nullOr types.int);
        };
        "unavailableReplicas" = mkOption {
          description = "Total number of unavailable pods targeted by this deployment.";
          type = (types.nullOr types.int);
        };
        "updatedReplicas" = mkOption {
          description =
            "Total number of non-terminated pods targeted by this deployment that have the desired template spec.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "availableReplicas" = mkOverride 1002 null;
        "collisionCount" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "readyReplicas" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "unavailableReplicas" = mkOverride 1002 null;
        "updatedReplicas" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description =
            "Rolling update config params. Present only if DeploymentStrategyType = RollingUpdate.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollingUpdateDeployment"));
        };
        "type" = mkOption {
          description =
            ''Type of deployment. Can be "Recreate" or "RollingUpdate". Default is RollingUpdate.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.FSGroupStrategyOptions" = {

      options = {
        "ranges" = mkOption {
          description =
            "Ranges are the allowed ranges of fs groups.  If you would like to force a single fs group then supply a single range with the same start and end.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IDRange")));
        };
        "rule" = mkOption {
          description =
            "Rule is the strategy that will dictate what FSGroup is used in the SecurityContext.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ranges" = mkOverride 1002 null;
        "rule" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.HTTPIngressPath" = {

      options = {
        "backend" = mkOption {
          description =
            "Backend defines the referenced service endpoint to which the traffic will be forwarded to.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressBackend");
        };
        "path" = mkOption {
          description = ''
            Path is an extended POSIX regex as defined by IEEE Std 1003.1, (i.e this follows the egrep/unix syntax, not the perl syntax) matched against the path of an incoming request. Currently it can contain characters disallowed from the conventional "path" part of a URL as defined by RFC 3986. Paths must begin with a '/'. If unspecified, the path defaults to a catch all sending traffic to the backend.'';
          type = (types.nullOr types.str);
        };
      };

      config = { "path" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.HTTPIngressRuleValue" = {

      options = {
        "paths" = mkOption {
          description = "A collection of paths that map requests to backends.";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.HTTPIngressPath"));
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.HostPortRange" = {

      options = {
        "max" = mkOption {
          description = "max is the end of the range, inclusive.";
          type = types.int;
        };
        "min" = mkOption {
          description = "min is the start of the range, inclusive.";
          type = types.int;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IDRange" = {

      options = {
        "max" = mkOption {
          description = "Max is the end of the range, inclusive.";
          type = types.int;
        };
        "min" = mkOption {
          description = "Min is the start of the range, inclusive.";
          type = types.int;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Ingress" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec is the desired state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressSpec"));
        };
        "status" = mkOption {
          description =
            "Status is the current state of the Ingress. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressBackend" = {

      options = {
        "serviceName" = mkOption {
          description = "Specifies the name of the referenced service.";
          type = types.str;
        };
        "servicePort" = mkOption {
          description = "Specifies the port of the referenced service.";
          type = (types.either types.int types.str);
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of Ingress.";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Ingress"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressRule" = {

      options = {
        "host" = mkOption {
          description = ''
            Host is the fully qualified domain name of a network host, as defined by RFC 3986. Note the following deviations from the "host" part of the URI as defined in the RFC: 1. IPs are not allowed. Currently an IngressRuleValue can only apply to the
            	  IP in the Spec of the parent Ingress.
            2. The `:` delimiter is not respected because ports are not allowed.
            	  Currently the port of an Ingress is implicitly :80 for http and
            	  :443 for https.
            Both these may change in the future. Incoming requests are matched against the host before the IngressRuleValue. If the host is unspecified, the Ingress routes all traffic based on the specified IngressRuleValue.'';
          type = (types.nullOr types.str);
        };
        "http" = mkOption {
          description = "";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.HTTPIngressRuleValue"));
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "http" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressSpec" = {

      options = {
        "backend" = mkOption {
          description =
            "A default backend capable of servicing requests that don't match any rule. At least one of 'backend' or 'rules' must be specified. This field is optional to allow the loadbalancer controller or defaulting logic to specify a global default.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressBackend"));
        };
        "rules" = mkOption {
          description =
            "A list of host rules used to configure the Ingress. If unspecified, or no rule matches, all traffic is sent to the default backend.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressRule")));
        };
        "tls" = mkOption {
          description =
            "TLS configuration. Currently the Ingress only supports a single TLS port, 443. If multiple members of this list specify different hosts, they will be multiplexed on the same port according to the hostname specified through the SNI TLS extension, if the ingress controller fulfilling the ingress supports SNI.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressTLS")));
        };
      };

      config = {
        "backend" = mkOverride 1002 null;
        "rules" = mkOverride 1002 null;
        "tls" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressStatus" = {

      options = {
        "loadBalancer" = mkOption {
          description = "LoadBalancer contains the current status of the load-balancer.";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.LoadBalancerStatus"));
        };
      };

      config = { "loadBalancer" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IngressTLS" = {

      options = {
        "hosts" = mkOption {
          description =
            "Hosts are a list of hosts included in the TLS certificate. The values in this list must match the name/s used in the tlsSecret. Defaults to the wildcard host setting for the loadbalancer controller fulfilling this Ingress, if left unspecified.";
          type = (types.nullOr (types.listOf types.str));
        };
        "secretName" = mkOption {
          description = ''
            SecretName is the name of the secret used to terminate SSL traffic on 443. Field is left optional to allow SSL routing based on SNI hostname alone. If the SNI host in a listener conflicts with the "Host" header field used by an IngressRule, the SNI host is used for termination and value of the Host header is used for routing.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hosts" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicy" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior for this NetworkPolicy.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicySpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyIngressRule" = {

      options = {
        "from" = mkOption {
          description =
            "List of sources which should be able to access the pods selected for this rule. Items in this list are combined using a logical OR operation. If this field is empty or missing, this rule matches all sources (traffic not restricted by source). If this field is present and contains at least on item, this rule allows traffic only if the traffic matches at least one item in the from list.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyPeer")));
        };
        "ports" = mkOption {
          description =
            "List of ports which should be made accessible on the pods selected for this rule. Each item in this list is combined using a logical OR. If this field is empty or missing, this rule matches all ports (traffic not restricted by port). If this field is present and contains at least one item, then this rule allows traffic only if the traffic matches at least one port in the list.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyPort")));
        };
      };

      config = {
        "from" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of schema objects.";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicy"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyPeer" = {

      options = {
        "namespaceSelector" = mkOption {
          description =
            "Selects Namespaces using cluster scoped-labels.  This matches all pods in all namespaces selected by this label selector. This field follows standard label selector semantics. If present but empty, this selector selects all namespaces.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "podSelector" = mkOption {
          description =
            "This is a label selector which selects Pods in this namespace. This field follows standard label selector semantics. If present but empty, this selector selects all pods in this namespace.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
      };

      config = {
        "namespaceSelector" = mkOverride 1002 null;
        "podSelector" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyPort" = {

      options = {
        "port" = mkOption {
          description =
            "If specified, the port on the given protocol.  This can either be a numerical or named port on a pod.  If this field is not provided, this matches all port names and numbers. If present, only traffic on the specified protocol AND port will be matched.";
          type = (types.nullOr (types.either types.int types.str));
        };
        "protocol" = mkOption {
          description =
            "Optional.  The protocol (TCP or UDP) which traffic must match. If not specified, this field defaults to TCP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "port" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicySpec" = {

      options = {
        "ingress" = mkOption {
          description =
            "List of ingress rules to be applied to the selected pods. Traffic is allowed to a pod if there are no NetworkPolicies selecting the pod OR if the traffic source is the pod's local node, OR if the traffic matches at least one ingress rule across all of the NetworkPolicy objects whose podSelector matches the pod. If this field is empty then this NetworkPolicy does not allow any traffic (and serves solely to ensure that the pods it selects are isolated by default).";
          type = (types.nullOr (types.listOf (submoduleOf
            "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicyIngressRule")));
        };
        "podSelector" = mkOption {
          description =
            "Selects the pods to which this NetworkPolicy object applies.  The array of ingress rules is applied to any pods selected by this field. Multiple network policies can select the same set of pods.  In this case, the ingress rules for each are combined additively. This field is NOT optional and follows standard label selector semantics. An empty podSelector matches all pods in this namespace.";
          type = (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector");
        };
      };

      config = { "ingress" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicy" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "spec defines the policy enforced.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicySpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicyList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of schema objects.";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicy"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicySpec" = {

      options = {
        "allowedCapabilities" = mkOption {
          description =
            "AllowedCapabilities is a list of capabilities that can be requested to add to the container. Capabilities in this field may be added at the pod author's discretion. You must not list a capability in both AllowedCapabilities and RequiredDropCapabilities.";
          type = (types.nullOr (types.listOf types.str));
        };
        "defaultAddCapabilities" = mkOption {
          description =
            "DefaultAddCapabilities is the default set of capabilities that will be added to the container unless the pod spec specifically drops the capability.  You may not list a capabiility in both DefaultAddCapabilities and RequiredDropCapabilities.";
          type = (types.nullOr (types.listOf types.str));
        };
        "fsGroup" = mkOption {
          description =
            "FSGroup is the strategy that will dictate what fs group is used by the SecurityContext.";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.FSGroupStrategyOptions");
        };
        "hostIPC" = mkOption {
          description =
            "hostIPC determines if the policy allows the use of HostIPC in the pod spec.";
          type = (types.nullOr types.bool);
        };
        "hostNetwork" = mkOption {
          description =
            "hostNetwork determines if the policy allows the use of HostNetwork in the pod spec.";
          type = (types.nullOr types.bool);
        };
        "hostPID" = mkOption {
          description =
            "hostPID determines if the policy allows the use of HostPID in the pod spec.";
          type = (types.nullOr types.bool);
        };
        "hostPorts" = mkOption {
          description = "hostPorts determines which host port ranges are allowed to be exposed.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.HostPortRange")));
        };
        "privileged" = mkOption {
          description = "privileged determines if a pod can request to be run as privileged.";
          type = (types.nullOr types.bool);
        };
        "readOnlyRootFilesystem" = mkOption {
          description =
            "ReadOnlyRootFilesystem when set to true will force containers to run with a read only root file system.  If the container specifically requests to run with a non-read only root file system the PSP should deny the pod. If set to false the container may run with a read only root file system if it wishes but it will not be forced to.";
          type = (types.nullOr types.bool);
        };
        "requiredDropCapabilities" = mkOption {
          description =
            "RequiredDropCapabilities are the capabilities that will be dropped from the container.  These are required to be dropped and cannot be added.";
          type = (types.nullOr (types.listOf types.str));
        };
        "runAsUser" = mkOption {
          description =
            "runAsUser is the strategy that will dictate the allowable RunAsUser values that may be set.";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RunAsUserStrategyOptions");
        };
        "seLinux" = mkOption {
          description =
            "seLinux is the strategy that will dictate the allowable labels that may be set.";
          type =
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.SELinuxStrategyOptions");
        };
        "supplementalGroups" = mkOption {
          description =
            "SupplementalGroups is the strategy that will dictate what supplemental groups are used by the SecurityContext.";
          type = (submoduleOf
            "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.SupplementalGroupsStrategyOptions");
        };
        "volumes" = mkOption {
          description =
            "volumes is a white list of allowed volume plugins.  Empty indicates that all plugins may be used.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "allowedCapabilities" = mkOverride 1002 null;
        "defaultAddCapabilities" = mkOverride 1002 null;
        "hostIPC" = mkOverride 1002 null;
        "hostNetwork" = mkOverride 1002 null;
        "hostPID" = mkOverride 1002 null;
        "hostPorts" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "requiredDropCapabilities" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSet" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "If the Labels of a ReplicaSet are empty, they are defaulted to be the same as the Pod(s) that the ReplicaSet manages. Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "Spec defines the specification of the desired behavior of the ReplicaSet. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetSpec"));
        };
        "status" = mkOption {
          description =
            "Status is the most recently observed status of the ReplicaSet. This data may be out of date by some window of time. Populated by the system. Read-only. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetCondition" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "The last time the condition transitioned from one status to another.";
          type = (types.nullOr types.str);
        };
        "message" = mkOption {
          description = "A human readable message indicating details about the transition.";
          type = (types.nullOr types.str);
        };
        "reason" = mkOption {
          description = "The reason for the condition's last transition.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "Type of replica set condition.";
          type = types.str;
        };
      };

      config = {
        "lastTransitionTime" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "reason" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description =
            "List of ReplicaSets. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSet"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetSpec" = {

      options = {
        "minReadySeconds" = mkOption {
          description =
            "Minimum number of seconds for which a newly created pod should be ready without any of its container crashing, for it to be considered available. Defaults to 0 (pod will be considered available as soon as it is ready)";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Replicas is the number of desired replicas. This is a pointer to distinguish between explicit zero and unspecified. Defaults to 1. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/#what-is-a-replicationcontroller";
          type = (types.nullOr types.int);
        };
        "selector" = mkOption {
          description =
            "Selector is a label query over pods that should match the replica count. If the selector is empty, it is defaulted to the labels present on the pod template. Label keys and values that must match in order to be controlled by this replica set. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "template" = mkOption {
          description =
            "Template is the object that describes the pod that will be created if insufficient replicas are detected. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.PodTemplateSpec"));
        };
      };

      config = {
        "minReadySeconds" = mkOverride 1002 null;
        "replicas" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "template" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetStatus" = {

      options = {
        "availableReplicas" = mkOption {
          description =
            "The number of available replicas (ready for at least minReadySeconds) for this replica set.";
          type = (types.nullOr types.int);
        };
        "conditions" = mkOption {
          description =
            "Represents the latest available observations of a replica set's current state.";
          type = (types.nullOr (coerceAttrsOfSubmodulesToListByKey
            "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSetCondition" "type"));
          apply = values: if values != null then mapAttrsToList (n: v: v) values else values;
        };
        "fullyLabeledReplicas" = mkOption {
          description =
            "The number of pods that have labels matching the labels of the pod template of the replicaset.";
          type = (types.nullOr types.int);
        };
        "observedGeneration" = mkOption {
          description =
            "ObservedGeneration reflects the generation of the most recently observed ReplicaSet.";
          type = (types.nullOr types.int);
        };
        "readyReplicas" = mkOption {
          description = "The number of ready replicas for this replica set.";
          type = (types.nullOr types.int);
        };
        "replicas" = mkOption {
          description =
            "Replicas is the most recently oberved number of replicas. More info: https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/#what-is-a-replicationcontroller";
          type = types.int;
        };
      };

      config = {
        "availableReplicas" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "fullyLabeledReplicas" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "readyReplicas" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollbackConfig" = {

      options = {
        "revision" = mkOption {
          description = "The revision to rollback to. If set to 0, rollback to the last revision.";
          type = (types.nullOr types.int);
        };
      };

      config = { "revision" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollingUpdateDaemonSet" = {

      options = {
        "maxUnavailable" = mkOption {
          description =
            "The maximum number of DaemonSet pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of total number of DaemonSet pods at the start of the update (ex: 10%). Absolute number is calculated from percentage by rounding up. This cannot be 0. Default value is 1. Example: when this is set to 30%, at most 30% of the total number of nodes that should be running the daemon pod (i.e. status.desiredNumberScheduled) can have their pods stopped for an update at any given time. The update starts by stopping at most 30% of those DaemonSet pods and then brings up new DaemonSet pods in their place. Once the new pods are available, it then proceeds onto other DaemonSet pods, thus ensuring that at least 70% of original number of DaemonSet pods are available at all times during the update.";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = { "maxUnavailable" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RollingUpdateDeployment" = {

      options = {
        "maxSurge" = mkOption {
          description =
            "The maximum number of pods that can be scheduled above the desired number of pods. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number is calculated from percentage by rounding up. By default, a value of 1 is used. Example: when this is set to 30%, the new RC can be scaled up immediately when the rolling update starts, such that the total number of old and new pods do not exceed 130% of desired pods. Once old pods have been killed, new RC can be scaled up further, ensuring that total number of pods running at any time during the update is atmost 130% of desired pods.";
          type = (types.nullOr (types.either types.int types.str));
        };
        "maxUnavailable" = mkOption {
          description =
            "The maximum number of pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). Absolute number is calculated from percentage by rounding down. This can not be 0 if MaxSurge is 0. By default, a fixed value of 1 is used. Example: when this is set to 30%, the old RC can be scaled down to 70% of desired pods immediately when the rolling update starts. Once new pods are ready, old RC can be scaled down further, followed by scaling up the new RC, ensuring that the total number of pods available at all times during the update is at least 70% of desired pods.";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxSurge" = mkOverride 1002 null;
        "maxUnavailable" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.RunAsUserStrategyOptions" = {

      options = {
        "ranges" = mkOption {
          description = "Ranges are the allowed ranges of uids that may be used.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IDRange")));
        };
        "rule" = mkOption {
          description =
            "Rule is the strategy that will dictate the allowable RunAsUser values that may be set.";
          type = types.str;
        };
      };

      config = { "ranges" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.SELinuxStrategyOptions" = {

      options = {
        "rule" = mkOption {
          description =
            "type is the strategy that will dictate the allowable labels that may be set.";
          type = types.str;
        };
        "seLinuxOptions" = mkOption {
          description =
            "seLinuxOptions required to run as; required for MustRunAs More info: https://git.k8s.io/community/contributors/design-proposals/security_context.md";
          type = (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.api.v1.SELinuxOptions"));
        };
      };

      config = { "seLinuxOptions" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Scale" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object metadata; More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description =
            "defines the behavior of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status.";
          type =
            (types.nullOr (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ScaleSpec"));
        };
        "status" = mkOption {
          description =
            "current status of the scale. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#spec-and-status. Read-only.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ScaleStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ScaleSpec" = {

      options = {
        "replicas" = mkOption {
          description = "desired number of instances for the scaled object.";
          type = (types.nullOr types.int);
        };
      };

      config = { "replicas" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ScaleStatus" = {

      options = {
        "replicas" = mkOption {
          description = "actual number of observed instances of the scaled object.";
          type = types.int;
        };
        "selector" = mkOption {
          description =
            "label query over pods that should match the replicas count. More info: http://kubernetes.io/docs/user-guide/labels#label-selectors";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "targetSelector" = mkOption {
          description =
            "label selector for pods that should match the replicas count. This is a serializated version of both map-based and more expressive set-based selectors. This is done to avoid introspection in the clients. The string will be in the same format as the query-param syntax. If the target type only supports map-based selectors, both this field and map-based selector field are populated. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "selector" = mkOverride 1002 null;
        "targetSelector" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.SupplementalGroupsStrategyOptions" = {

      options = {
        "ranges" = mkOption {
          description =
            "Ranges are the allowed ranges of supplemental groups.  If you would like to force a single supplemental group then supply a single range with the same start and end.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.IDRange")));
        };
        "rule" = mkOption {
          description =
            "Rule is the strategy that will dictate what supplemental groups is used in the SecurityContext.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ranges" = mkOverride 1002 null;
        "rule" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ThirdPartyResource" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "description" = mkOption {
          description = "Description is the description of this object.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "versions" = mkOption {
          description = "Versions are versions for this third party object";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.APIVersion")));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "description" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "versions" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ThirdPartyResourceList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of ThirdPartyResources.";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ThirdPartyResource"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard list metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicy" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior for this NetworkPolicy.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicySpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyIngressRule" = {

      options = {
        "from" = mkOption {
          description =
            "List of sources which should be able to access the pods selected for this rule. Items in this list are combined using a logical OR operation. If this field is empty or missing, this rule matches all sources (traffic not restricted by source). If this field is present and contains at least on item, this rule allows traffic only if the traffic matches at least one item in the from list.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyPeer")));
        };
        "ports" = mkOption {
          description =
            "List of ports which should be made accessible on the pods selected for this rule. Each item in this list is combined using a logical OR. If this field is empty or missing, this rule matches all ports (traffic not restricted by port). If this field is present and contains at least one item, then this rule allows traffic only if the traffic matches at least one port in the list.";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyPort")));
        };
      };

      config = {
        "from" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of schema objects.";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicy"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyPeer" = {

      options = {
        "namespaceSelector" = mkOption {
          description =
            "Selects Namespaces using cluster scoped-labels. This matches all pods in all namespaces selected by this label selector. This field follows standard label selector semantics. If present but empty, this selector selects all namespaces.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "podSelector" = mkOption {
          description =
            "This is a label selector which selects Pods in this namespace. This field follows standard label selector semantics. If present but empty, this selector selects all pods in this namespace.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
      };

      config = {
        "namespaceSelector" = mkOverride 1002 null;
        "podSelector" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyPort" = {

      options = {
        "port" = mkOption {
          description =
            "The port on the given protocol. This can either be a numerical or named port on a pod. If this field is not provided, this matches all port names and numbers.";
          type = (types.nullOr (types.either types.int types.str));
        };
        "protocol" = mkOption {
          description =
            "The protocol (TCP or UDP) which traffic must match. If not specified, this field defaults to TCP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "port" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicySpec" = {

      options = {
        "ingress" = mkOption {
          description =
            "List of ingress rules to be applied to the selected pods. Traffic is allowed to a pod if there are no NetworkPolicies selecting the pod (and cluster policy otherwise allows the traffic), OR if the traffic source is the pod's local node, OR if the traffic matches at least one ingress rule across all of the NetworkPolicy objects whose podSelector matches the pod. If this field is empty then this NetworkPolicy does not allow any traffic (and serves solely to ensure that the pods it selects are isolated by default)";
          type = (types.nullOr (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicyIngressRule")));
        };
        "podSelector" = mkOption {
          description =
            "Selects the pods to which this NetworkPolicy object applies. The array of ingress rules is applied to any pods selected by this field. Multiple network policies can select the same set of pods. In this case, the ingress rules for each are combined additively. This field is NOT optional and follows standard label selector semantics. An empty podSelector matches all pods in this namespace.";
          type = (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector");
        };
      };

      config = { "ingress" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.policy.v1beta1.Eviction" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "deleteOptions" = mkOption {
          description = "DeleteOptions may be provided";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.DeleteOptions"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "ObjectMeta describes the pod that is being evicted.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "deleteOptions" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudget" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the PodDisruptionBudget.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudgetSpec"));
        };
        "status" = mkOption {
          description = "Most recently observed status of the PodDisruptionBudget.";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudgetStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudgetList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudget"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudgetSpec" = {

      options = {
        "maxUnavailable" = mkOption {
          description = ''
            An eviction is allowed if at most "maxUnavailable" pods selected by "selector" are unavailable after the eviction, i.e. even in absence of the evicted pod. For example, one can prevent all voluntary evictions by specifying 0. This is a mutually exclusive setting with "minAvailable".'';
          type = (types.nullOr (types.either types.int types.str));
        };
        "minAvailable" = mkOption {
          description = ''
            An eviction is allowed if at least "minAvailable" pods selected by "selector" will still be available after the eviction, i.e. even in the absence of the evicted pod.  So for example you can prevent all voluntary evictions by specifying "100%".'';
          type = (types.nullOr (types.either types.int types.str));
        };
        "selector" = mkOption {
          description =
            "Label query over pods whose evictions are managed by the disruption budget.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
      };

      config = {
        "maxUnavailable" = mkOverride 1002 null;
        "minAvailable" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudgetStatus" = {

      options = {
        "currentHealthy" = mkOption {
          description = "current number of healthy pods";
          type = types.int;
        };
        "desiredHealthy" = mkOption {
          description = "minimum desired number of healthy pods";
          type = types.int;
        };
        "disruptedPods" = mkOption {
          description =
            "DisruptedPods contains information about pods whose eviction was processed by the API server eviction subresource handler but has not yet been observed by the PodDisruptionBudget controller. A pod will be in this map from the time when the API server processed the eviction request to the time when the pod is seen by PDB controller as having been marked for deletion (or after a timeout). The key in the map is the name of the pod and the value is the time when the API server processed the eviction request. If the deletion didn't occur and a pod is still there it will be removed from the list automatically by PodDisruptionBudget controller after some time. If everything goes smooth this map should be empty for the most of the time. Large number of entries in the map may indicate problems with pod deletions.";
          type = (types.attrsOf types.str);
        };
        "disruptionsAllowed" = mkOption {
          description = "Number of pod disruptions that are currently allowed.";
          type = types.int;
        };
        "expectedPods" = mkOption {
          description = "total number of pods counted by this disruption budget";
          type = types.int;
        };
        "observedGeneration" = mkOption {
          description =
            "Most recent generation observed when updating this PDB status. PodDisruptionsAllowed and other status informatio is valid only if observedGeneration equals to PDB's object generation.";
          type = (types.nullOr types.int);
        };
      };

      config = { "observedGeneration" = mkOverride 1002 null; };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRole" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "rules" = mkOption {
          description = "Rules holds all the PolicyRules for this ClusterRole";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.PolicyRule"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRoleBinding" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "roleRef" = mkOption {
          description =
            "RoleRef can only reference a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleRef");
        };
        "subjects" = mkOption {
          description = "Subjects holds references to the objects the role applies to.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.Subject"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRoleBindingList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of ClusterRoleBindings";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRoleBinding"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRoleList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of ClusterRoles";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRole"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.PolicyRule" = {

      options = {
        "apiGroups" = mkOption {
          description =
            "APIGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.";
          type = (types.nullOr (types.listOf types.str));
        };
        "nonResourceURLs" = mkOption {
          description = ''
            NonResourceURLs is a set of partial urls that a user should have access to.  *s are allowed, but only as the full, final step in the path This name is intentionally different than the internal type so that the DefaultConvert works nicely and because the ordering may be different. Since non-resource URLs are not namespaced, this field is only applicable for ClusterRoles referenced from a ClusterRoleBinding. Rules can either apply to API resources (such as "pods" or "secrets") or non-resource URL paths (such as "/api"),  but not both.'';
          type = (types.nullOr (types.listOf types.str));
        };
        "resourceNames" = mkOption {
          description =
            "ResourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.";
          type = (types.nullOr (types.listOf types.str));
        };
        "resources" = mkOption {
          description =
            "Resources is a list of resources this rule applies to.  ResourceAll represents all resources.";
          type = (types.nullOr (types.listOf types.str));
        };
        "verbs" = mkOption {
          description =
            "Verbs is a list of Verbs that apply to ALL the ResourceKinds and AttributeRestrictions contained in this rule.  VerbAll represents all kinds.";
          type = (types.listOf types.str);
        };
      };

      config = {
        "apiGroups" = mkOverride 1002 null;
        "nonResourceURLs" = mkOverride 1002 null;
        "resourceNames" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.Role" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "rules" = mkOption {
          description = "Rules holds all the PolicyRules for this Role";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.PolicyRule"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleBinding" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "roleRef" = mkOption {
          description =
            "RoleRef can reference a Role in the current namespace or a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleRef");
        };
        "subjects" = mkOption {
          description = "Subjects holds references to the objects the role applies to.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.Subject"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleBindingList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of RoleBindings";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleBinding"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of Roles";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.Role"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced";
          type = types.str;
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.Subject" = {

      options = {
        "apiVersion" = mkOption {
          description = ''
            APIVersion holds the API group and version of the referenced subject. Defaults to "v1" for ServiceAccount subjects. Defaults to "rbac.authorization.k8s.io/v1alpha1" for User and Group subjects.'';
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = ''
            Kind of object being referenced. Values defined by this API group are "User", "Group", and "ServiceAccount". If the Authorizer does not recognized the kind value, the Authorizer should report an error.'';
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the object being referenced.";
          type = types.str;
        };
        "namespace" = mkOption {
          description = ''
            Namespace of the referenced object.  If the object kind is non-namespace, such as "User" or "Group", and this value is not empty the Authorizer should report an error.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRole" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "rules" = mkOption {
          description = "Rules holds all the PolicyRules for this ClusterRole";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.PolicyRule"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRoleBinding" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "roleRef" = mkOption {
          description =
            "RoleRef can only reference a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleRef");
        };
        "subjects" = mkOption {
          description = "Subjects holds references to the objects the role applies to.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Subject"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRoleBindingList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of ClusterRoleBindings";
          type = (types.listOf
            (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRoleBinding"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRoleList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of ClusterRoles";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRole"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.PolicyRule" = {

      options = {
        "apiGroups" = mkOption {
          description =
            "APIGroups is the name of the APIGroup that contains the resources.  If multiple API groups are specified, any action requested against one of the enumerated resources in any API group will be allowed.";
          type = (types.nullOr (types.listOf types.str));
        };
        "nonResourceURLs" = mkOption {
          description = ''
            NonResourceURLs is a set of partial urls that a user should have access to.  *s are allowed, but only as the full, final step in the path Since non-resource URLs are not namespaced, this field is only applicable for ClusterRoles referenced from a ClusterRoleBinding. Rules can either apply to API resources (such as "pods" or "secrets") or non-resource URL paths (such as "/api"),  but not both.'';
          type = (types.nullOr (types.listOf types.str));
        };
        "resourceNames" = mkOption {
          description =
            "ResourceNames is an optional white list of names that the rule applies to.  An empty set means that everything is allowed.";
          type = (types.nullOr (types.listOf types.str));
        };
        "resources" = mkOption {
          description =
            "Resources is a list of resources this rule applies to.  ResourceAll represents all resources.";
          type = (types.nullOr (types.listOf types.str));
        };
        "verbs" = mkOption {
          description =
            "Verbs is a list of Verbs that apply to ALL the ResourceKinds and AttributeRestrictions contained in this rule.  VerbAll represents all kinds.";
          type = (types.listOf types.str);
        };
      };

      config = {
        "apiGroups" = mkOverride 1002 null;
        "nonResourceURLs" = mkOverride 1002 null;
        "resourceNames" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Role" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "rules" = mkOption {
          description = "Rules holds all the PolicyRules for this Role";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.PolicyRule"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleBinding" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "roleRef" = mkOption {
          description =
            "RoleRef can reference a Role in the current namespace or a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.";
          type = (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleRef");
        };
        "subjects" = mkOption {
          description = "Subjects holds references to the objects the role applies to.";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Subject"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleBindingList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of RoleBindings";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleBinding"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of Roles";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Role"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced";
          type = types.str;
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = { };

    };
    "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Subject" = {

      options = {
        "apiGroup" = mkOption {
          description = ''
            APIGroup holds the API group of the referenced subject. Defaults to "" for ServiceAccount subjects. Defaults to "rbac.authorization.k8s.io" for User and Group subjects.'';
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = ''
            Kind of object being referenced. Values defined by this API group are "User", "Group", and "ServiceAccount". If the Authorizer does not recognized the kind value, the Authorizer should report an error.'';
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the object being referenced.";
          type = types.str;
        };
        "namespace" = mkOption {
          description = ''
            Namespace of the referenced object.  If the object kind is non-namespace, such as "User" or "Group", and this value is not empty the Authorizer should report an error.'';
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPreset" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr
            (submoduleOf "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPresetSpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPresetList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is a list of schema objects.";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPreset"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPresetSpec" = {

      options = {
        "env" = mkOption {
          description = "Env defines the collection of EnvVar to inject into containers.";
          type = (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EnvVar")));
        };
        "envFrom" = mkOption {
          description =
            "EnvFrom defines the collection of EnvFromSource to inject into containers.";
          type = (types.nullOr
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.EnvFromSource")));
        };
        "selector" = mkOption {
          description =
            "Selector is a label query over a set of resources, in this case pods. Required.";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector"));
        };
        "volumeMounts" = mkOption {
          description =
            "VolumeMounts defines the collection of VolumeMount to inject into containers.";
          type =
            (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.VolumeMount")));
        };
        "volumes" = mkOption {
          description = "Volumes defines the collection of Volume to inject into the pod.";
          type = (types.nullOr (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.api.v1.Volume")));
        };
      };

      config = {
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.storage.v1.StorageClass" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "parameters" = mkOption {
          description =
            "Parameters holds the parameters for the provisioner that should create volumes of this storage class.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "provisioner" = mkOption {
          description = "Provisioner indicates the type of the provisioner.";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.storage.v1.StorageClassList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of StorageClasses";
          type = (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.storage.v1.StorageClass"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.storage.v1beta1.StorageClass" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "parameters" = mkOption {
          description =
            "Parameters holds the parameters for the provisioner that should create volumes of this storage class.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "provisioner" = mkOption {
          description = "Provisioner indicates the type of the provisioner.";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
      };

    };
    "io.k8s.kubernetes.pkg.apis.storage.v1beta1.StorageClassList" = {

      options = {
        "apiVersion" = mkOption {
          description =
            "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "items" = mkOption {
          description = "Items is the list of StorageClasses";
          type =
            (types.listOf (submoduleOf "io.k8s.kubernetes.pkg.apis.storage.v1beta1.StorageClass"));
        };
        "kind" = mkOption {
          description =
            "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description =
            "Standard list metadata More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ListMeta"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };

  };
in {
  # all resource versions
  options = {
    resources = {
      "apiregistration.k8s.io"."v1beta1"."APIService" = mkOption {
        description = ''
          APIService represents a server for a particular GroupVersion. Name must be "version.group".'';
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIService" "apiservices"
          "APIService" "apiregistration.k8s.io" "v1beta1"));
        default = { };
      };
      "core"."v1"."Binding" = mkOption {
        description =
          "Binding ties one object to another; for example, a pod is bound to a node by a scheduler. Deprecated in 1.7, please use the bindings subresource of pods instead.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Binding" "bindings" "Binding" "core"
            "v1"));
        default = { };
      };
      "core"."v1"."ConfigMap" = mkOption {
        description = "ConfigMap holds configuration data for pods to consume.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ConfigMap" "configmaps" "ConfigMap"
            "core" "v1"));
        default = { };
      };
      "core"."v1"."Endpoints" = mkOption {
        description = ''
          Endpoints is a collection of endpoints that implement the actual service. Example:
            Name: "mysvc",
            Subsets: [
              {
                Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
                Ports: [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
              },
              {
                Addresses: [{"ip": "10.10.3.3"}],
                Ports: [{"name": "a", "port": 93}, {"name": "b", "port": 76}]
              },
           ]'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Endpoints" "endpoints" "Endpoints"
            "core" "v1"));
        default = { };
      };
      "core"."v1"."Event" = mkOption {
        description = "Event is a report of an event somewhere in the cluster.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Event" "events" "Event" "core"
            "v1"));
        default = { };
      };
      "core"."v1"."LimitRange" = mkOption {
        description =
          "LimitRange sets resource usage limits for each kind of resource in a Namespace.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.LimitRange" "limitranges"
            "LimitRange" "core" "v1"));
        default = { };
      };
      "core"."v1"."Namespace" = mkOption {
        description =
          "Namespace provides a scope for Names. Use of multiple namespaces is optional.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Namespace" "namespaces" "Namespace"
            "core" "v1"));
        default = { };
      };
      "core"."v1"."Node" = mkOption {
        description =
          "Node is a worker node in Kubernetes. Each node will have a unique identifier in the cache (i.e. in etcd).";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Node" "nodes" "Node" "core" "v1"));
        default = { };
      };
      "core"."v1"."PersistentVolume" = mkOption {
        description =
          "PersistentVolume (PV) is a storage resource provisioned by an administrator. It is analogous to a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.PersistentVolume"
            "persistentvolumes" "PersistentVolume" "core" "v1"));
        default = { };
      };
      "core"."v1"."PersistentVolumeClaim" = mkOption {
        description =
          "PersistentVolumeClaim is a user's request for and claim to a persistent volume";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaim"
            "persistentvolumeclaims" "PersistentVolumeClaim" "core" "v1"));
        default = { };
      };
      "core"."v1"."Pod" = mkOption {
        description =
          "Pod is a collection of containers that can run on a host. This resource is created by clients and scheduled onto hosts.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Pod" "pods" "Pod" "core" "v1"));
        default = { };
      };
      "core"."v1"."PodTemplate" = mkOption {
        description = "PodTemplate describes a template for creating copies of a predefined pod.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.PodTemplate" "podtemplates"
            "PodTemplate" "core" "v1"));
        default = { };
      };
      "core"."v1"."ReplicationController" = mkOption {
        description =
          "ReplicationController represents the configuration of a replication controller.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ReplicationController"
            "replicationcontrollers" "ReplicationController" "core" "v1"));
        default = { };
      };
      "core"."v1"."ResourceQuota" = mkOption {
        description = "ResourceQuota sets aggregate quota restrictions enforced per namespace";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ResourceQuota" "resourcequotas"
            "ResourceQuota" "core" "v1"));
        default = { };
      };
      "core"."v1"."Secret" = mkOption {
        description =
          "Secret holds secret data of a certain type. The total bytes of the values in the Data field must be less than MaxSecretSize bytes.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Secret" "secrets" "Secret" "core"
            "v1"));
        default = { };
      };
      "core"."v1"."Service" = mkOption {
        description =
          "Service is a named abstraction of software service (for example, mysql) consisting of local port (for example 3306) that the proxy listens on, and the selector that determines which pods will answer requests sent through the proxy.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Service" "services" "Service" "core"
            "v1"));
        default = { };
      };
      "core"."v1"."ServiceAccount" = mkOption {
        description =
          "ServiceAccount binds together: * a name, understood by users, and perhaps by peripheral systems, for an identity * a principal that can be authenticated and authorized * a set of secrets";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ServiceAccount" "serviceaccounts"
            "ServiceAccount" "core" "v1"));
        default = { };
      };
      "admissionregistration.k8s.io"."v1alpha1"."ExternalAdmissionHookConfiguration" = mkOption {
        description =
          "ExternalAdmissionHookConfiguration describes the configuration of initializers.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHookConfiguration"
          "externaladmissionhookconfigurations" "ExternalAdmissionHookConfiguration"
          "admissionregistration.k8s.io" "v1alpha1"));
        default = { };
      };
      "admissionregistration.k8s.io"."v1alpha1"."InitializerConfiguration" = mkOption {
        description = "InitializerConfiguration describes the configuration of initializers.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.InitializerConfiguration"
          "initializerconfigurations" "InitializerConfiguration" "admissionregistration.k8s.io"
          "v1alpha1"));
        default = { };
      };
      "apps"."v1beta1"."ControllerRevision" = mkOption {
        description =
          "ControllerRevision implements an immutable snapshot of state data. Clients are responsible for serializing and deserializing the objects that contain their internal state. Once a ControllerRevision has been successfully created, it can not be updated. The API Server will fail validation of all requests that attempt to mutate the Data field. ControllerRevisions may, however, be deleted. Note that, due to its use by both the DaemonSet and StatefulSet controllers for update and rollback, this object is beta. However, it may be subject to name and representation changes in future releases, and clients should not depend on its stability. It is primarily for internal use by controllers.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ControllerRevision"
            "controllerrevisions" "ControllerRevision" "apps" "v1beta1"));
        default = { };
      };
      "apps"."v1beta1"."Deployment" = mkOption {
        description = "Deployment enables declarative updates for Pods and ReplicaSets.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.Deployment" "deployments"
            "Deployment" "apps" "v1beta1"));
        default = { };
      };
      "apps"."v1beta1"."DeploymentRollback" = mkOption {
        description =
          "DeploymentRollback stores the information required to rollback a deployment.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentRollback"
            "rollback" "DeploymentRollback" "apps" "v1beta1"));
        default = { };
      };
      "apps"."v1beta1"."StatefulSet" = mkOption {
        description = ''
          StatefulSet represents a set of pods with consistent identities. Identities are defined as:
           - Network: A single stable DNS and hostname.
           - Storage: As many VolumeClaims as requested.
          The StatefulSet guarantees that a given network identity will always map to the same storage identity.'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSet"
            "statefulsets" "StatefulSet" "apps" "v1beta1"));
        default = { };
      };
      "authentication.k8s.io"."v1"."TokenReview" = mkOption {
        description =
          "TokenReview attempts to authenticate a token to a known user. Note: TokenReview requests may be cached by the webhook token authenticator plugin in the kube-apiserver.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReview"
            "tokenreviews" "TokenReview" "authentication.k8s.io" "v1"));
        default = { };
      };
      "authentication.k8s.io"."v1beta1"."TokenReview" = mkOption {
        description =
          "TokenReview attempts to authenticate a token to a known user. Note: TokenReview requests may be cached by the webhook token authenticator plugin in the kube-apiserver.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.authentication.v1beta1.TokenReview"
            "tokenreviews" "TokenReview" "authentication.k8s.io" "v1beta1"));
        default = { };
      };
      "authorization.k8s.io"."v1"."LocalSubjectAccessReview" = mkOption {
        description =
          "LocalSubjectAccessReview checks whether or not a user or group can perform an action in a given namespace. Having a namespace scoped resource makes it much easier to grant namespace scoped policy that includes permissions checking.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1.LocalSubjectAccessReview"
          "localsubjectaccessreviews" "LocalSubjectAccessReview" "authorization.k8s.io" "v1"));
        default = { };
      };
      "authorization.k8s.io"."v1"."SelfSubjectAccessReview" = mkOption {
        description = ''
          SelfSubjectAccessReview checks whether or the current user can perform an action.  Not filling in a spec.namespace means "in all namespaces".  Self is a special case, because users should always be able to check whether they can perform an action'';
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1.SelfSubjectAccessReview"
          "selfsubjectaccessreviews" "SelfSubjectAccessReview" "authorization.k8s.io" "v1"));
        default = { };
      };
      "authorization.k8s.io"."v1"."SubjectAccessReview" = mkOption {
        description =
          "SubjectAccessReview checks whether or not a user or group can perform an action.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReview"
            "subjectaccessreviews" "SubjectAccessReview" "authorization.k8s.io" "v1"));
        default = { };
      };
      "authorization.k8s.io"."v1beta1"."LocalSubjectAccessReview" = mkOption {
        description =
          "LocalSubjectAccessReview checks whether or not a user or group can perform an action in a given namespace. Having a namespace scoped resource makes it much easier to grant namespace scoped policy that includes permissions checking.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.LocalSubjectAccessReview"
          "localsubjectaccessreviews" "LocalSubjectAccessReview" "authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "authorization.k8s.io"."v1beta1"."SelfSubjectAccessReview" = mkOption {
        description = ''
          SelfSubjectAccessReview checks whether or the current user can perform an action.  Not filling in a spec.namespace means "in all namespaces".  Self is a special case, because users should always be able to check whether they can perform an action'';
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SelfSubjectAccessReview"
          "selfsubjectaccessreviews" "SelfSubjectAccessReview" "authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "authorization.k8s.io"."v1beta1"."SubjectAccessReview" = mkOption {
        description =
          "SubjectAccessReview checks whether or not a user or group can perform an action.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1beta1.SubjectAccessReview"
          "subjectaccessreviews" "SubjectAccessReview" "authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "autoscaling"."v1"."HorizontalPodAutoscaler" = mkOption {
        description = "configuration of a horizontal pod autoscaler.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscaler"
          "horizontalpodautoscalers" "HorizontalPodAutoscaler" "autoscaling" "v1"));
        default = { };
      };
      "autoscaling"."v2alpha1"."HorizontalPodAutoscaler" = mkOption {
        description =
          "HorizontalPodAutoscaler is the configuration for a horizontal pod autoscaler, which automatically manages the replica count of any resource implementing the scale subresource based on the metrics specified.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.autoscaling.v2alpha1.HorizontalPodAutoscaler"
          "horizontalpodautoscalers" "HorizontalPodAutoscaler" "autoscaling" "v2alpha1"));
        default = { };
      };
      "batch"."v1"."Job" = mkOption {
        description = "Job represents the configuration of a single job.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.batch.v1.Job" "jobs" "Job" "batch"
            "v1"));
        default = { };
      };
      "batch"."v2alpha1"."CronJob" = mkOption {
        description = "CronJob represents the configuration of a single cron job.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJob" "cronjobs"
            "CronJob" "batch" "v2alpha1"));
        default = { };
      };
      "certificates.k8s.io"."v1beta1"."CertificateSigningRequest" = mkOption {
        description = "Describes a certificate signing request";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequest"
          "certificatesigningrequests" "CertificateSigningRequest" "certificates.k8s.io"
          "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."DaemonSet" = mkOption {
        description = "DaemonSet represents the configuration of a daemon set.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSet"
            "daemonsets" "DaemonSet" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."Deployment" = mkOption {
        description = "Deployment enables declarative updates for Pods and ReplicaSets.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Deployment"
            "deployments" "Deployment" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."DeploymentRollback" = mkOption {
        description =
          "DeploymentRollback stores the information required to rollback a deployment.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DeploymentRollback"
            "rollback" "DeploymentRollback" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."Ingress" = mkOption {
        description =
          "Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Ingress"
            "ingresses" "Ingress" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."NetworkPolicy" = mkOption {
        description = "NetworkPolicy describes what network traffic is allowed for a set of Pods";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.NetworkPolicy"
            "networkpolicies" "NetworkPolicy" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."PodSecurityPolicy" = mkOption {
        description =
          "Pod Security Policy governs the ability to make requests that affect the Security Context that will be applied to a pod and container.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicy"
            "podsecuritypolicies" "PodSecurityPolicy" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."ReplicaSet" = mkOption {
        description = "ReplicaSet represents the configuration of a ReplicaSet.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSet"
            "replicasets" "ReplicaSet" "extensions" "v1beta1"));
        default = { };
      };
      "extensions"."v1beta1"."ThirdPartyResource" = mkOption {
        description =
          "A ThirdPartyResource is a generic representation of a resource, it is used by add-ons and plugins to add new resource types to the API.  It consists of one or more Versions of the api.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ThirdPartyResource"
            "thirdpartyresources" "ThirdPartyResource" "extensions" "v1beta1"));
        default = { };
      };
      "networking.k8s.io"."v1"."NetworkPolicy" = mkOption {
        description = "NetworkPolicy describes what network traffic is allowed for a set of Pods";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicy"
            "networkpolicies" "NetworkPolicy" "networking.k8s.io" "v1"));
        default = { };
      };
      "policy"."v1beta1"."Eviction" = mkOption {
        description =
          "Eviction evicts a pod from its node subject to certain policies and safety constraints. This is a subresource of Pod.  A request to cause such an eviction is created by POSTing to .../pods/u003cpod nameu003e/evictions.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.policy.v1beta1.Eviction" "eviction"
            "Eviction" "policy" "v1beta1"));
        default = { };
      };
      "policy"."v1beta1"."PodDisruptionBudget" = mkOption {
        description =
          "PodDisruptionBudget is an object to define the max disruption that can be caused to a collection of pods";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudget"
            "poddisruptionbudgets" "PodDisruptionBudget" "policy" "v1beta1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1alpha1"."ClusterRole" = mkOption {
        description =
          "ClusterRole is a cluster level, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding or ClusterRoleBinding.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRole"
            "clusterroles" "ClusterRole" "rbac.authorization.k8s.io" "v1alpha1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1alpha1"."ClusterRoleBinding" = mkOption {
        description =
          "ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.ClusterRoleBinding"
            "clusterrolebindings" "ClusterRoleBinding" "rbac.authorization.k8s.io" "v1alpha1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1alpha1"."Role" = mkOption {
        description =
          "Role is a namespaced, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.Role" "roles" "Role"
            "rbac.authorization.k8s.io" "v1alpha1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1alpha1"."RoleBinding" = mkOption {
        description =
          "RoleBinding references a role, but does not contain it.  It can reference a Role in the same namespace or a ClusterRole in the global namespace. It adds who information via Subjects and namespace information by which namespace it exists in.  RoleBindings in a given namespace only have effect in that namespace.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1alpha1.RoleBinding"
            "rolebindings" "RoleBinding" "rbac.authorization.k8s.io" "v1alpha1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1beta1"."ClusterRole" = mkOption {
        description =
          "ClusterRole is a cluster level, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding or ClusterRoleBinding.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRole"
            "clusterroles" "ClusterRole" "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1beta1"."ClusterRoleBinding" = mkOption {
        description =
          "ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRoleBinding"
            "clusterrolebindings" "ClusterRoleBinding" "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1beta1"."Role" = mkOption {
        description =
          "Role is a namespaced, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Role" "roles" "Role"
            "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "rbac.authorization.k8s.io"."v1beta1"."RoleBinding" = mkOption {
        description =
          "RoleBinding references a role, but does not contain it.  It can reference a Role in the same namespace or a ClusterRole in the global namespace. It adds who information via Subjects and namespace information by which namespace it exists in.  RoleBindings in a given namespace only have effect in that namespace.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleBinding"
            "rolebindings" "RoleBinding" "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "settings.k8s.io"."v1alpha1"."PodPreset" = mkOption {
        description =
          "PodPreset is a policy resource that defines additional runtime requirements for a Pod.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPreset"
            "podpresets" "PodPreset" "settings.k8s.io" "v1alpha1"));
        default = { };
      };
      "storage.k8s.io"."v1"."StorageClass" = mkOption {
        description = ''
          StorageClass describes the parameters for a class of storage for which PersistentVolumes can be dynamically provisioned.

          StorageClasses are non-namespaced; the name of the storage class according to etcd is in ObjectMeta.Name.'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.storage.v1.StorageClass"
            "storageclasses" "StorageClass" "storage.k8s.io" "v1"));
        default = { };
      };
      "storage.k8s.io"."v1beta1"."StorageClass" = mkOption {
        description = ''
          StorageClass describes the parameters for a class of storage for which PersistentVolumes can be dynamically provisioned.

          StorageClasses are non-namespaced; the name of the storage class according to etcd is in ObjectMeta.Name.'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.storage.v1beta1.StorageClass"
            "storageclasses" "StorageClass" "storage.k8s.io" "v1beta1"));
        default = { };
      };

    } // {
      "APIServices" = mkOption {
        description = ''
          APIService represents a server for a particular GroupVersion. Name must be "version.group".'';
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kube-aggregator.pkg.apis.apiregistration.v1beta1.APIService" "apiservices"
          "APIService" "apiregistration.k8s.io" "v1beta1"));
        default = { };
      };
      "bindings" = mkOption {
        description =
          "Binding ties one object to another; for example, a pod is bound to a node by a scheduler. Deprecated in 1.7, please use the bindings subresource of pods instead.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Binding" "bindings" "Binding" "core"
            "v1"));
        default = { };
      };
      "certificateSigningRequests" = mkOption {
        description = "Describes a certificate signing request";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.certificates.v1beta1.CertificateSigningRequest"
          "certificatesigningrequests" "CertificateSigningRequest" "certificates.k8s.io"
          "v1beta1"));
        default = { };
      };
      "clusterRoles" = mkOption {
        description =
          "ClusterRole is a cluster level, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding or ClusterRoleBinding.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRole"
            "clusterroles" "ClusterRole" "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "clusterRoleBindings" = mkOption {
        description =
          "ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.ClusterRoleBinding"
            "clusterrolebindings" "ClusterRoleBinding" "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "configMaps" = mkOption {
        description = "ConfigMap holds configuration data for pods to consume.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ConfigMap" "configmaps" "ConfigMap"
            "core" "v1"));
        default = { };
      };
      "controllerRevisions" = mkOption {
        description =
          "ControllerRevision implements an immutable snapshot of state data. Clients are responsible for serializing and deserializing the objects that contain their internal state. Once a ControllerRevision has been successfully created, it can not be updated. The API Server will fail validation of all requests that attempt to mutate the Data field. ControllerRevisions may, however, be deleted. Note that, due to its use by both the DaemonSet and StatefulSet controllers for update and rollback, this object is beta. However, it may be subject to name and representation changes in future releases, and clients should not depend on its stability. It is primarily for internal use by controllers.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.ControllerRevision"
            "controllerrevisions" "ControllerRevision" "apps" "v1beta1"));
        default = { };
      };
      "cronJobs" = mkOption {
        description = "CronJob represents the configuration of a single cron job.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.batch.v2alpha1.CronJob" "cronjobs"
            "CronJob" "batch" "v2alpha1"));
        default = { };
      };
      "daemonSets" = mkOption {
        description = "DaemonSet represents the configuration of a daemon set.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.DaemonSet"
            "daemonsets" "DaemonSet" "extensions" "v1beta1"));
        default = { };
      };
      "deployments" = mkOption {
        description = "Deployment enables declarative updates for Pods and ReplicaSets.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.Deployment" "deployments"
            "Deployment" "apps" "v1beta1"));
        default = { };
      };
      "rollback" = mkOption {
        description =
          "DeploymentRollback stores the information required to rollback a deployment.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.DeploymentRollback"
            "rollback" "DeploymentRollback" "apps" "v1beta1"));
        default = { };
      };
      "endpoints" = mkOption {
        description = ''
          Endpoints is a collection of endpoints that implement the actual service. Example:
            Name: "mysvc",
            Subsets: [
              {
                Addresses: [{"ip": "10.10.1.1"}, {"ip": "10.10.2.2"}],
                Ports: [{"name": "a", "port": 8675}, {"name": "b", "port": 309}]
              },
              {
                Addresses: [{"ip": "10.10.3.3"}],
                Ports: [{"name": "a", "port": 93}, {"name": "b", "port": 76}]
              },
           ]'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Endpoints" "endpoints" "Endpoints"
            "core" "v1"));
        default = { };
      };
      "events" = mkOption {
        description = "Event is a report of an event somewhere in the cluster.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Event" "events" "Event" "core"
            "v1"));
        default = { };
      };
      "eviction" = mkOption {
        description =
          "Eviction evicts a pod from its node subject to certain policies and safety constraints. This is a subresource of Pod.  A request to cause such an eviction is created by POSTing to .../pods/u003cpod nameu003e/evictions.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.policy.v1beta1.Eviction" "eviction"
            "Eviction" "policy" "v1beta1"));
        default = { };
      };
      "externalAdmissionHookConfigurations" = mkOption {
        description =
          "ExternalAdmissionHookConfiguration describes the configuration of initializers.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.ExternalAdmissionHookConfiguration"
          "externaladmissionhookconfigurations" "ExternalAdmissionHookConfiguration"
          "admissionregistration.k8s.io" "v1alpha1"));
        default = { };
      };
      "horizontalPodAutoscalers" = mkOption {
        description = "configuration of a horizontal pod autoscaler.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.autoscaling.v1.HorizontalPodAutoscaler"
          "horizontalpodautoscalers" "HorizontalPodAutoscaler" "autoscaling" "v1"));
        default = { };
      };
      "ingresses" = mkOption {
        description =
          "Ingress is a collection of rules that allow inbound connections to reach the endpoints defined by a backend. An Ingress can be configured to give services externally-reachable urls, load balance traffic, terminate SSL, offer name based virtual hosting etc.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.Ingress"
            "ingresses" "Ingress" "extensions" "v1beta1"));
        default = { };
      };
      "initializerConfigurations" = mkOption {
        description = "InitializerConfiguration describes the configuration of initializers.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.admissionregistration.v1alpha1.InitializerConfiguration"
          "initializerconfigurations" "InitializerConfiguration" "admissionregistration.k8s.io"
          "v1alpha1"));
        default = { };
      };
      "jobs" = mkOption {
        description = "Job represents the configuration of a single job.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.batch.v1.Job" "jobs" "Job" "batch"
            "v1"));
        default = { };
      };
      "limitRanges" = mkOption {
        description =
          "LimitRange sets resource usage limits for each kind of resource in a Namespace.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.LimitRange" "limitranges"
            "LimitRange" "core" "v1"));
        default = { };
      };
      "localSubjectAccessReviews" = mkOption {
        description =
          "LocalSubjectAccessReview checks whether or not a user or group can perform an action in a given namespace. Having a namespace scoped resource makes it much easier to grant namespace scoped policy that includes permissions checking.";
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1.LocalSubjectAccessReview"
          "localsubjectaccessreviews" "LocalSubjectAccessReview" "authorization.k8s.io" "v1"));
        default = { };
      };
      "namespaces" = mkOption {
        description =
          "Namespace provides a scope for Names. Use of multiple namespaces is optional.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Namespace" "namespaces" "Namespace"
            "core" "v1"));
        default = { };
      };
      "networkPolicies" = mkOption {
        description = "NetworkPolicy describes what network traffic is allowed for a set of Pods";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.networking.v1.NetworkPolicy"
            "networkpolicies" "NetworkPolicy" "networking.k8s.io" "v1"));
        default = { };
      };
      "nodes" = mkOption {
        description =
          "Node is a worker node in Kubernetes. Each node will have a unique identifier in the cache (i.e. in etcd).";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Node" "nodes" "Node" "core" "v1"));
        default = { };
      };
      "persistentVolumes" = mkOption {
        description =
          "PersistentVolume (PV) is a storage resource provisioned by an administrator. It is analogous to a node. More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.PersistentVolume"
            "persistentvolumes" "PersistentVolume" "core" "v1"));
        default = { };
      };
      "persistentVolumeClaims" = mkOption {
        description =
          "PersistentVolumeClaim is a user's request for and claim to a persistent volume";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.PersistentVolumeClaim"
            "persistentvolumeclaims" "PersistentVolumeClaim" "core" "v1"));
        default = { };
      };
      "pods" = mkOption {
        description =
          "Pod is a collection of containers that can run on a host. This resource is created by clients and scheduled onto hosts.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Pod" "pods" "Pod" "core" "v1"));
        default = { };
      };
      "podDisruptionBudgets" = mkOption {
        description =
          "PodDisruptionBudget is an object to define the max disruption that can be caused to a collection of pods";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.policy.v1beta1.PodDisruptionBudget"
            "poddisruptionbudgets" "PodDisruptionBudget" "policy" "v1beta1"));
        default = { };
      };
      "podPresets" = mkOption {
        description =
          "PodPreset is a policy resource that defines additional runtime requirements for a Pod.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.settings.v1alpha1.PodPreset"
            "podpresets" "PodPreset" "settings.k8s.io" "v1alpha1"));
        default = { };
      };
      "podSecurityPolicies" = mkOption {
        description =
          "Pod Security Policy governs the ability to make requests that affect the Security Context that will be applied to a pod and container.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.PodSecurityPolicy"
            "podsecuritypolicies" "PodSecurityPolicy" "extensions" "v1beta1"));
        default = { };
      };
      "podTemplates" = mkOption {
        description = "PodTemplate describes a template for creating copies of a predefined pod.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.PodTemplate" "podtemplates"
            "PodTemplate" "core" "v1"));
        default = { };
      };
      "replicaSets" = mkOption {
        description = "ReplicaSet represents the configuration of a ReplicaSet.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ReplicaSet"
            "replicasets" "ReplicaSet" "extensions" "v1beta1"));
        default = { };
      };
      "replicationControllers" = mkOption {
        description =
          "ReplicationController represents the configuration of a replication controller.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ReplicationController"
            "replicationcontrollers" "ReplicationController" "core" "v1"));
        default = { };
      };
      "resourceQuotas" = mkOption {
        description = "ResourceQuota sets aggregate quota restrictions enforced per namespace";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ResourceQuota" "resourcequotas"
            "ResourceQuota" "core" "v1"));
        default = { };
      };
      "roles" = mkOption {
        description =
          "Role is a namespaced, logical grouping of PolicyRules that can be referenced as a unit by a RoleBinding.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.Role" "roles" "Role"
            "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "roleBindings" = mkOption {
        description =
          "RoleBinding references a role, but does not contain it.  It can reference a Role in the same namespace or a ClusterRole in the global namespace. It adds who information via Subjects and namespace information by which namespace it exists in.  RoleBindings in a given namespace only have effect in that namespace.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.rbac.v1beta1.RoleBinding"
            "rolebindings" "RoleBinding" "rbac.authorization.k8s.io" "v1beta1"));
        default = { };
      };
      "secrets" = mkOption {
        description =
          "Secret holds secret data of a certain type. The total bytes of the values in the Data field must be less than MaxSecretSize bytes.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Secret" "secrets" "Secret" "core"
            "v1"));
        default = { };
      };
      "selfSubjectAccessReviews" = mkOption {
        description = ''
          SelfSubjectAccessReview checks whether or the current user can perform an action.  Not filling in a spec.namespace means "in all namespaces".  Self is a special case, because users should always be able to check whether they can perform an action'';
        type = (types.attrsOf (submoduleForDefinition
          "io.k8s.kubernetes.pkg.apis.authorization.v1.SelfSubjectAccessReview"
          "selfsubjectaccessreviews" "SelfSubjectAccessReview" "authorization.k8s.io" "v1"));
        default = { };
      };
      "services" = mkOption {
        description =
          "Service is a named abstraction of software service (for example, mysql) consisting of local port (for example 3306) that the proxy listens on, and the selector that determines which pods will answer requests sent through the proxy.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.Service" "services" "Service" "core"
            "v1"));
        default = { };
      };
      "serviceAccounts" = mkOption {
        description =
          "ServiceAccount binds together: * a name, understood by users, and perhaps by peripheral systems, for an identity * a principal that can be authenticated and authorized * a set of secrets";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.api.v1.ServiceAccount" "serviceaccounts"
            "ServiceAccount" "core" "v1"));
        default = { };
      };
      "statefulSets" = mkOption {
        description = ''
          StatefulSet represents a set of pods with consistent identities. Identities are defined as:
           - Network: A single stable DNS and hostname.
           - Storage: As many VolumeClaims as requested.
          The StatefulSet guarantees that a given network identity will always map to the same storage identity.'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.apps.v1beta1.StatefulSet"
            "statefulsets" "StatefulSet" "apps" "v1beta1"));
        default = { };
      };
      "storageClasses" = mkOption {
        description = ''
          StorageClass describes the parameters for a class of storage for which PersistentVolumes can be dynamically provisioned.

          StorageClasses are non-namespaced; the name of the storage class according to etcd is in ObjectMeta.Name.'';
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.storage.v1.StorageClass"
            "storageclasses" "StorageClass" "storage.k8s.io" "v1"));
        default = { };
      };
      "subjectAccessReviews" = mkOption {
        description =
          "SubjectAccessReview checks whether or not a user or group can perform an action.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.authorization.v1.SubjectAccessReview"
            "subjectaccessreviews" "SubjectAccessReview" "authorization.k8s.io" "v1"));
        default = { };
      };
      "thirdPartyResources" = mkOption {
        description =
          "A ThirdPartyResource is a generic representation of a resource, it is used by add-ons and plugins to add new resource types to the API.  It consists of one or more Versions of the api.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.extensions.v1beta1.ThirdPartyResource"
            "thirdpartyresources" "ThirdPartyResource" "extensions" "v1beta1"));
        default = { };
      };
      "tokenReviews" = mkOption {
        description =
          "TokenReview attempts to authenticate a token to a known user. Note: TokenReview requests may be cached by the webhook token authenticator plugin in the kube-apiserver.";
        type = (types.attrsOf
          (submoduleForDefinition "io.k8s.kubernetes.pkg.apis.authentication.v1.TokenReview"
            "tokenreviews" "TokenReview" "authentication.k8s.io" "v1"));
        default = { };
      };

    };
  };

  config = {
    # expose resource definitions
    inherit definitions;

    # register resource types
    types = [
      {
        name = "apiservices";
        group = "apiregistration.k8s.io";
        version = "v1beta1";
        kind = "APIService";
        attrName = "APIServices";
      }
      {
        name = "bindings";
        group = "core";
        version = "v1";
        kind = "Binding";
        attrName = "bindings";
      }
      {
        name = "configmaps";
        group = "core";
        version = "v1";
        kind = "ConfigMap";
        attrName = "configMaps";
      }
      {
        name = "endpoints";
        group = "core";
        version = "v1";
        kind = "Endpoints";
        attrName = "endpoints";
      }
      {
        name = "events";
        group = "core";
        version = "v1";
        kind = "Event";
        attrName = "events";
      }
      {
        name = "limitranges";
        group = "core";
        version = "v1";
        kind = "LimitRange";
        attrName = "limitRanges";
      }
      {
        name = "namespaces";
        group = "core";
        version = "v1";
        kind = "Namespace";
        attrName = "namespaces";
      }
      {
        name = "nodes";
        group = "core";
        version = "v1";
        kind = "Node";
        attrName = "nodes";
      }
      {
        name = "persistentvolumes";
        group = "core";
        version = "v1";
        kind = "PersistentVolume";
        attrName = "persistentVolumes";
      }
      {
        name = "persistentvolumeclaims";
        group = "core";
        version = "v1";
        kind = "PersistentVolumeClaim";
        attrName = "persistentVolumeClaims";
      }
      {
        name = "pods";
        group = "core";
        version = "v1";
        kind = "Pod";
        attrName = "pods";
      }
      {
        name = "podtemplates";
        group = "core";
        version = "v1";
        kind = "PodTemplate";
        attrName = "podTemplates";
      }
      {
        name = "replicationcontrollers";
        group = "core";
        version = "v1";
        kind = "ReplicationController";
        attrName = "replicationControllers";
      }
      {
        name = "resourcequotas";
        group = "core";
        version = "v1";
        kind = "ResourceQuota";
        attrName = "resourceQuotas";
      }
      {
        name = "secrets";
        group = "core";
        version = "v1";
        kind = "Secret";
        attrName = "secrets";
      }
      {
        name = "services";
        group = "core";
        version = "v1";
        kind = "Service";
        attrName = "services";
      }
      {
        name = "serviceaccounts";
        group = "core";
        version = "v1";
        kind = "ServiceAccount";
        attrName = "serviceAccounts";
      }
      {
        name = "externaladmissionhookconfigurations";
        group = "admissionregistration.k8s.io";
        version = "v1alpha1";
        kind = "ExternalAdmissionHookConfiguration";
        attrName = "externalAdmissionHookConfigurations";
      }
      {
        name = "initializerconfigurations";
        group = "admissionregistration.k8s.io";
        version = "v1alpha1";
        kind = "InitializerConfiguration";
        attrName = "initializerConfigurations";
      }
      {
        name = "controllerrevisions";
        group = "apps";
        version = "v1beta1";
        kind = "ControllerRevision";
        attrName = "controllerRevisions";
      }
      {
        name = "deployments";
        group = "apps";
        version = "v1beta1";
        kind = "Deployment";
        attrName = "deployments";
      }
      {
        name = "rollback";
        group = "apps";
        version = "v1beta1";
        kind = "DeploymentRollback";
        attrName = "rollback";
      }
      {
        name = "statefulsets";
        group = "apps";
        version = "v1beta1";
        kind = "StatefulSet";
        attrName = "statefulSets";
      }
      {
        name = "tokenreviews";
        group = "authentication.k8s.io";
        version = "v1";
        kind = "TokenReview";
        attrName = "tokenReviews";
      }
      {
        name = "tokenreviews";
        group = "authentication.k8s.io";
        version = "v1beta1";
        kind = "TokenReview";
        attrName = "tokenReviews";
      }
      {
        name = "localsubjectaccessreviews";
        group = "authorization.k8s.io";
        version = "v1";
        kind = "LocalSubjectAccessReview";
        attrName = "localSubjectAccessReviews";
      }
      {
        name = "selfsubjectaccessreviews";
        group = "authorization.k8s.io";
        version = "v1";
        kind = "SelfSubjectAccessReview";
        attrName = "selfSubjectAccessReviews";
      }
      {
        name = "subjectaccessreviews";
        group = "authorization.k8s.io";
        version = "v1";
        kind = "SubjectAccessReview";
        attrName = "subjectAccessReviews";
      }
      {
        name = "localsubjectaccessreviews";
        group = "authorization.k8s.io";
        version = "v1beta1";
        kind = "LocalSubjectAccessReview";
        attrName = "localSubjectAccessReviews";
      }
      {
        name = "selfsubjectaccessreviews";
        group = "authorization.k8s.io";
        version = "v1beta1";
        kind = "SelfSubjectAccessReview";
        attrName = "selfSubjectAccessReviews";
      }
      {
        name = "subjectaccessreviews";
        group = "authorization.k8s.io";
        version = "v1beta1";
        kind = "SubjectAccessReview";
        attrName = "subjectAccessReviews";
      }
      {
        name = "horizontalpodautoscalers";
        group = "autoscaling";
        version = "v1";
        kind = "HorizontalPodAutoscaler";
        attrName = "horizontalPodAutoscalers";
      }
      {
        name = "horizontalpodautoscalers";
        group = "autoscaling";
        version = "v2alpha1";
        kind = "HorizontalPodAutoscaler";
        attrName = "horizontalPodAutoscalers";
      }
      {
        name = "jobs";
        group = "batch";
        version = "v1";
        kind = "Job";
        attrName = "jobs";
      }
      {
        name = "cronjobs";
        group = "batch";
        version = "v2alpha1";
        kind = "CronJob";
        attrName = "cronJobs";
      }
      {
        name = "certificatesigningrequests";
        group = "certificates.k8s.io";
        version = "v1beta1";
        kind = "CertificateSigningRequest";
        attrName = "certificateSigningRequests";
      }
      {
        name = "daemonsets";
        group = "extensions";
        version = "v1beta1";
        kind = "DaemonSet";
        attrName = "daemonSets";
      }
      {
        name = "deployments";
        group = "extensions";
        version = "v1beta1";
        kind = "Deployment";
        attrName = "deployments";
      }
      {
        name = "rollback";
        group = "extensions";
        version = "v1beta1";
        kind = "DeploymentRollback";
        attrName = "rollback";
      }
      {
        name = "ingresses";
        group = "extensions";
        version = "v1beta1";
        kind = "Ingress";
        attrName = "ingresses";
      }
      {
        name = "networkpolicies";
        group = "extensions";
        version = "v1beta1";
        kind = "NetworkPolicy";
        attrName = "networkPolicies";
      }
      {
        name = "podsecuritypolicies";
        group = "extensions";
        version = "v1beta1";
        kind = "PodSecurityPolicy";
        attrName = "podSecurityPolicies";
      }
      {
        name = "replicasets";
        group = "extensions";
        version = "v1beta1";
        kind = "ReplicaSet";
        attrName = "replicaSets";
      }
      {
        name = "thirdpartyresources";
        group = "extensions";
        version = "v1beta1";
        kind = "ThirdPartyResource";
        attrName = "thirdPartyResources";
      }
      {
        name = "networkpolicies";
        group = "networking.k8s.io";
        version = "v1";
        kind = "NetworkPolicy";
        attrName = "networkPolicies";
      }
      {
        name = "eviction";
        group = "policy";
        version = "v1beta1";
        kind = "Eviction";
        attrName = "eviction";
      }
      {
        name = "poddisruptionbudgets";
        group = "policy";
        version = "v1beta1";
        kind = "PodDisruptionBudget";
        attrName = "podDisruptionBudgets";
      }
      {
        name = "clusterroles";
        group = "rbac.authorization.k8s.io";
        version = "v1alpha1";
        kind = "ClusterRole";
        attrName = "clusterRoles";
      }
      {
        name = "clusterrolebindings";
        group = "rbac.authorization.k8s.io";
        version = "v1alpha1";
        kind = "ClusterRoleBinding";
        attrName = "clusterRoleBindings";
      }
      {
        name = "roles";
        group = "rbac.authorization.k8s.io";
        version = "v1alpha1";
        kind = "Role";
        attrName = "roles";
      }
      {
        name = "rolebindings";
        group = "rbac.authorization.k8s.io";
        version = "v1alpha1";
        kind = "RoleBinding";
        attrName = "roleBindings";
      }
      {
        name = "clusterroles";
        group = "rbac.authorization.k8s.io";
        version = "v1beta1";
        kind = "ClusterRole";
        attrName = "clusterRoles";
      }
      {
        name = "clusterrolebindings";
        group = "rbac.authorization.k8s.io";
        version = "v1beta1";
        kind = "ClusterRoleBinding";
        attrName = "clusterRoleBindings";
      }
      {
        name = "roles";
        group = "rbac.authorization.k8s.io";
        version = "v1beta1";
        kind = "Role";
        attrName = "roles";
      }
      {
        name = "rolebindings";
        group = "rbac.authorization.k8s.io";
        version = "v1beta1";
        kind = "RoleBinding";
        attrName = "roleBindings";
      }
      {
        name = "podpresets";
        group = "settings.k8s.io";
        version = "v1alpha1";
        kind = "PodPreset";
        attrName = "podPresets";
      }
      {
        name = "storageclasses";
        group = "storage.k8s.io";
        version = "v1";
        kind = "StorageClass";
        attrName = "storageClasses";
      }
      {
        name = "storageclasses";
        group = "storage.k8s.io";
        version = "v1beta1";
        kind = "StorageClass";
        attrName = "storageClasses";
      }
    ];

    resources = {
      "apiregistration.k8s.io"."v1beta1"."APIService" =
        mkAliasDefinitions options.resources."APIServices";
      "core"."v1"."Binding" = mkAliasDefinitions options.resources."bindings";
      "certificates.k8s.io"."v1beta1"."CertificateSigningRequest" =
        mkAliasDefinitions options.resources."certificateSigningRequests";
      "rbac.authorization.k8s.io"."v1beta1"."ClusterRole" =
        mkAliasDefinitions options.resources."clusterRoles";
      "rbac.authorization.k8s.io"."v1beta1"."ClusterRoleBinding" =
        mkAliasDefinitions options.resources."clusterRoleBindings";
      "core"."v1"."ConfigMap" = mkAliasDefinitions options.resources."configMaps";
      "apps"."v1beta1"."ControllerRevision" =
        mkAliasDefinitions options.resources."controllerRevisions";
      "batch"."v2alpha1"."CronJob" = mkAliasDefinitions options.resources."cronJobs";
      "extensions"."v1beta1"."DaemonSet" = mkAliasDefinitions options.resources."daemonSets";
      "apps"."v1beta1"."Deployment" = mkAliasDefinitions options.resources."deployments";
      "apps"."v1beta1"."DeploymentRollback" = mkAliasDefinitions options.resources."rollback";
      "core"."v1"."Endpoints" = mkAliasDefinitions options.resources."endpoints";
      "core"."v1"."Event" = mkAliasDefinitions options.resources."events";
      "policy"."v1beta1"."Eviction" = mkAliasDefinitions options.resources."eviction";
      "admissionregistration.k8s.io"."v1alpha1"."ExternalAdmissionHookConfiguration" =
        mkAliasDefinitions options.resources."externalAdmissionHookConfigurations";
      "autoscaling"."v1"."HorizontalPodAutoscaler" =
        mkAliasDefinitions options.resources."horizontalPodAutoscalers";
      "extensions"."v1beta1"."Ingress" = mkAliasDefinitions options.resources."ingresses";
      "admissionregistration.k8s.io"."v1alpha1"."InitializerConfiguration" =
        mkAliasDefinitions options.resources."initializerConfigurations";
      "batch"."v1"."Job" = mkAliasDefinitions options.resources."jobs";
      "core"."v1"."LimitRange" = mkAliasDefinitions options.resources."limitRanges";
      "authorization.k8s.io"."v1"."LocalSubjectAccessReview" =
        mkAliasDefinitions options.resources."localSubjectAccessReviews";
      "core"."v1"."Namespace" = mkAliasDefinitions options.resources."namespaces";
      "networking.k8s.io"."v1"."NetworkPolicy" =
        mkAliasDefinitions options.resources."networkPolicies";
      "core"."v1"."Node" = mkAliasDefinitions options.resources."nodes";
      "core"."v1"."PersistentVolume" = mkAliasDefinitions options.resources."persistentVolumes";
      "core"."v1"."PersistentVolumeClaim" =
        mkAliasDefinitions options.resources."persistentVolumeClaims";
      "core"."v1"."Pod" = mkAliasDefinitions options.resources."pods";
      "policy"."v1beta1"."PodDisruptionBudget" =
        mkAliasDefinitions options.resources."podDisruptionBudgets";
      "settings.k8s.io"."v1alpha1"."PodPreset" = mkAliasDefinitions options.resources."podPresets";
      "extensions"."v1beta1"."PodSecurityPolicy" =
        mkAliasDefinitions options.resources."podSecurityPolicies";
      "core"."v1"."PodTemplate" = mkAliasDefinitions options.resources."podTemplates";
      "extensions"."v1beta1"."ReplicaSet" = mkAliasDefinitions options.resources."replicaSets";
      "core"."v1"."ReplicationController" =
        mkAliasDefinitions options.resources."replicationControllers";
      "core"."v1"."ResourceQuota" = mkAliasDefinitions options.resources."resourceQuotas";
      "rbac.authorization.k8s.io"."v1beta1"."Role" = mkAliasDefinitions options.resources."roles";
      "rbac.authorization.k8s.io"."v1beta1"."RoleBinding" =
        mkAliasDefinitions options.resources."roleBindings";
      "core"."v1"."Secret" = mkAliasDefinitions options.resources."secrets";
      "authorization.k8s.io"."v1"."SelfSubjectAccessReview" =
        mkAliasDefinitions options.resources."selfSubjectAccessReviews";
      "core"."v1"."Service" = mkAliasDefinitions options.resources."services";
      "core"."v1"."ServiceAccount" = mkAliasDefinitions options.resources."serviceAccounts";
      "apps"."v1beta1"."StatefulSet" = mkAliasDefinitions options.resources."statefulSets";
      "storage.k8s.io"."v1"."StorageClass" = mkAliasDefinitions options.resources."storageClasses";
      "authorization.k8s.io"."v1"."SubjectAccessReview" =
        mkAliasDefinitions options.resources."subjectAccessReviews";
      "extensions"."v1beta1"."ThirdPartyResource" =
        mkAliasDefinitions options.resources."thirdPartyResources";
      "authentication.k8s.io"."v1"."TokenReview" =
        mkAliasDefinitions options.resources."tokenReviews";

    };
  };
}
